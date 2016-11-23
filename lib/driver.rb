require 'mysql'
require 'date'
require 'httparty'

class Driver

attr_reader :sites

def initialize(id)
@id = id
@sites = []
end

def find_sites
secret = ENV["HQ_SECRET"]
url = "/users/#{@id}/sites?timestamp=#{DateTime.now.strftime('%Q')}&key=#{ENV["HQ_KEY"]}"
digest = OpenSSL::Digest.new('sha1')
hmac = OpenSSL::HMAC.hexdigest(digest, secret, url)
temp_url="#{ENV["HQ_HOST_URL"]}#{url}&sign=#{hmac}"
response = HTTParty.get(temp_url)
response.parsed_response.each do |x|
begin
  @sites << x['url']
rescue TypeError
puts 'id does not exist'
end

end
@sites
end


end

