#!/usr/bin/ruby

require "httparty"

class UserApi
  include HTTParty
  base_uri "http://#{ARGV[0]}:3001"

  def initialize
    @headers = { "Content-Type" => "application/json" }
  end

  def create(user)
    self.class.post("/user", body: user, headers: @headers)
  end
end

user = {
  :full_name => "Tony Stark",
  :email => "tony@stark.com",
  :password => "pwd123",
}

puts UserApi.new.create(user.to_json)
