require 'uri'
require 'active_support/core_ext/hash/deep_merge'

class Params
  attr_accessor :params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    query = parse_www_encoded_form(req.query_string)
    body = parse_www_encoded_form(req.body)

    @params = {}
      .merge(query)
      .merge(body)
      .merge(route_params)
  end

  def [](key)
    @params[key]
  end

  def to_s
  end

  #private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    return {} if www_encoded_form.nil?

    hashes = URI.decode_www_form(www_encoded_form).map do |arr|
      key = parse_key(arr.first)
      val = [arr.last]
      new_arr = key.concat(val)
      new_arr.reverse.inject() { |x, y| Hash[y, x] }
    end

    new_hash = {}
    hashes.each do |elem|
      new_hash = hashes[0].deep_merge(elem)
    end

    new_hash
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split("[").map { |each_key| each_key.gsub("]","") }
  end
end
