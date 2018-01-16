#!/usr/bin/env ruby

require 'json'
require 'net/http'
require 'openssl'
require 'time'
require 'timeout'
require 'uri'
require 'yaml'

config = YAML.load(File.read('config.yml'))
url = config['url']
shared_secret = config['shared_secret']

def request(base_url, shared_secret, path, method = :Get)
  uri = URI.parse(base_url + path)
  req = Net::HTTP.const_get(method).new(uri)
  req['Authorization'] = "Bearer #{shared_secret}"
  req['Accept'] = 'application/json'
  http = Net::HTTP.new(uri.hostname, uri.port)
  http.use_ssl = uri.scheme == 'https'
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == 'https'
  res = http.start { |h| h.request(req) }
  return nil if res.code == '502' # server is rebooting; silently ignore
  JSON.load(res.body)
end

def log(line)
  line = "#{Time.now} #{line}"
  File.open('sendAll.log', 'a') { |f| f.puts line }
  puts line
end

def wrap(desc)
  yield
rescue => e
  log("Failed #{desc}: #{e.inspect}: #{e.backtrace}")
end

def launch(who, timeout, claim_only, start_at)
  pid = Process.spawn("\"C:\\Program Files\\AutoHotkey\\AutoHotkeyU64.exe\" sendAll.ahk #{who}#{' --claim-only' if claim_only}")
  log "waiting for #{pid} (#{who}), timeout #{timeout}#{', claim only' if claim_only}"
  timeout ||= 25 * 60
  timeout -= 60

  waiter_thread = Thread.new { Process.waitpid(pid) }
  # you get one minute to log something besides "Start", otherwise
  # we kill you
  begin
    Timeout.timeout(60) do
      waiter_thread.join
    end
	# already done? that was fast! probably a claim only
    log "#{pid} done"
    return
  rescue Timeout::Error
    unless check_started(who, start_at)
	  log "#{who} failed to start"
	  Process.kill('KILL', pid)
	  return
    end
	# this is the normal happy path, continue to a full wait below
  end

  begin
    Timeout.timeout(timeout) do
      waiter_thread.join
    end
    log "#{pid} done"
  rescue Timeout::Error
    log "timed out (#{who})"
    Process.kill('KILL', pid)
  end
end

def hearts_sent(who, start_at)
  File.open("Nox#{who}.log", 'rb') do |f|
    f.seek([f.size - 4096, 0].max)
    lines = f.readlines
    # ignore the first, probably partial, line
    lines.shift
    lines.each do |line|
      next unless line =~ /(\d+) Given/
      next unless Time.parse(line) > start_at
      return $1.to_i
    end
  end
  nil
end

def check_started(who, start_at)
  File.open("#{who}.log", 'rb') do |f|
    f.seek([f.size - 4096, 0].max)
    lines = f.readlines
    # ignore the first, probably partial, line
    lines.shift
    lines.each do |line|
      next if line =~ /Start/
      next unless Time.parse(line) > start_at
      return true
    end
  end
  false
end

players = request(url, shared_secret, "/").map { |x| x['name'] }
mutex = Mutex.new

players.map do |player|
  # stagger the thundering herd a bit
  sleep 5
  Thread.new do
    # clean up any old runs
    wrap("aborting previous runs for #{player}") do
      request(url, shared_secret, "#{player}/runs", :Delete)
    end

    last_loop = Time.now
    loop do
      failures = 0
      loop do
        status = wrap("fetching current status for #{player}") do
          request(url, shared_secret, "#{player}")
        end
        if status.nil?
          failures += 1
          # couldn't contact server, just run after 38 minutes
          break if failures >= 10 && (Time.now - last_loop) > 38 * 60
        else
          failures = 0
          break if status['run_now'] == true
        end
        sleep 30
      end
      mutex.synchronize do
        status = wrap("fetching current status for #{player}") do
          request(url, shared_secret, "#{player}")
        end
        # they paused while we were waiting to run
        next if status && status['run_now'] != true

        last_loop = Time.now
        wrap("starting run for #{player}") do
          request(url, shared_secret, "#{player}/runs", :Post)
        end
        launch("Nox#{player}", status && status['timeout'], status && status['claim_only'], last_loop)
        wrap("marking run complete for #{player}") do
          request(url, shared_secret, "#{player}/runs?hearts_given=#{hearts_sent(player, last_loop)}", :Delete)
        end
      end
    end
  end
end.each(&:join)
