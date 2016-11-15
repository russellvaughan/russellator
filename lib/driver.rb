require 'watir'
require 'phantomjs'
require 'Nokogiri'

class Driver 

attr_reader :sites

def initialize(url)
@url = url
@sites = []
end 

def find_sites
browser = Watir::Browser.new(:phantomjs)
browser.goto(@url)
document = Nokogiri::HTML.parse(browser.html)
if document.css('.caption')
document.css('.caption').each do |n|
@sites << n.search('h4').text
end
else puts 'no caption id present'
end
@sites
end


end

