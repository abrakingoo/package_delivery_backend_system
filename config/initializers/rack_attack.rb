Rack::Attack.cache.store = Rails.cache

Rack::Attack.throttle("auth/login/ip", limit: 5, period: 1.minute) do |req|
  req.ip if req.path == "/auth/login" && req.post?
end

Rack::Attack.throttle("auth/login/email", limit: 5, period: 1.minute) do |req|
  if req.path == "/auth/login" && req.post?
    body = JSON.parse(req.body.read) rescue {}
    req.body.rewind
    body.dig("user", "email")&.downcase&.strip
  end
end

Rack::Attack.throttle("auth/register/ip", limit: 10, period: 1.hour) do |req|
  req.ip if req.path == "/auth/register" && req.post?
end

Rack::Attack.throttle("delivery_request/ip", limit: 10, period: 1.minute) do |req|
  req.ip if req.path == "/delivery_request" && req.post?
end

Rack::Attack.throttle("driver/location/ip", limit: 60, period: 1.minute) do |req|
  req.ip if req.path == "/driver/location" && req.patch?
end

Rack::Attack.throttled_responder = lambda do |_req|
  [ 429, { "Content-Type" => "application/json" }, [ { error: "Too many requests. Please try again later." }.to_json ] ]
end
