class Rack::Attack
  # Configuración de cache
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
    url: ENV.fetch('REDIS_URL', 'redis://redis:6379/1')
  )

  # Throttle login attempts por IP
  throttle('login/ip', limit: 5, period: 60) do |req|
    req.ip if req.path == '/api/v1/auth/login' && req.post?
  end

  # Throttle register por IP
  throttle('register/ip', limit: 3, period: 300) do |req|
    req.ip if req.path == '/api/v1/auth/register' && req.post?
  end

  # Throttle general por IP
  throttle('req/ip', limit: 100, period: 60) do |req|
    req.ip
  end

  # Bloquear IPs que hacen demasiados requests
  blocklist('block excessive requests') do |req|
    Rack::Attack::Allow2Ban.filter(req.ip, maxretry: 10, findtime: 60, bantime: 600) do
      CGI.unescape(req.query_string) =~ /UNION/i ||
      req.path.include?('/etc/passwd') ||
      req.path.include?('..') ||
      req.user_agent == ''
    end
  end

  # Respuesta personalizada cuando se alcanza el límite
  self.throttled_responder = lambda do |env|
    retry_after = env['rack.attack.match_data'][:period]
    [
      429,
      {
        'Content-Type' => 'application/json',
        'Retry-After' => retry_after.to_s
      },
      [{
        success: false,
        message: 'Too many requests. Please try again later.',
        retry_after: retry_after
      }.to_json]
    ]
  end

  # Respuesta para IPs bloqueadas
  self.blocklisted_responder = lambda do |env|
    [
      403,
      { 'Content-Type' => 'application/json' },
      [{ success: false, message: 'Forbidden' }.to_json]
    ]
  end
end
