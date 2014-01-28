require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    @cookies = {}
    req.cookies.each do |cookie|
      if cookie.name == "_rails_lite_app"
        val = JSON.parse(cookie.value)
        @cookies[val.keys.first] = val.values.first
      end
    end
  end

  def [](key)
    @cookies[key]
  end

  def []=(key, val)
    @cookies[key] = val

    nil
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)

    res.cookies << WEBrick::Cookie.new('_rails_lite_app', @cookies.to_json)
  end
end
