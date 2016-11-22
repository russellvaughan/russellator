require './lib/driver'

class Qualifier

attr_reader :qualification

USER_SYSTEM = %w(sign\ in log\ in LOGIN log_in Login sign\ up register Sign\ In Sign\ Up Log\ in Sign\ in Log\ In)

def initialize(website)
    @website = website
    @qualification = {}
end

def qualify
@user_sites = Driver.new(@website).find_sites
num = 0
p @user_sites
while @user_sites == []  && num < 10
p "#{num += 1}"
@user_sites = Driver.new(@website).find_sites
p @user_sites
end
if num == 10 && @user_sites == []
@qualification['site']='no sites present'
else
qualify_user_sites
end
end

def qualify_user_sites
@num = 1
@user_sites.each do |site|
puts "this is the site #{site}"
@site = instance_variable_set("@site_#{@num}", Hash.new)
begin
  response = HTTParty.get(site)
rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
      Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, Errno::ETIMEDOUT => error
  puts "site"
  @site['url']=site
  puts "Site does not load: #{error}"
  @site['site_status']=error
  @site
  puts "\n\n"
  @qualification["site_#{@num}"]= @site
   puts @qualification
   @num += 1
end
   if response
    puts site
    @site['url']=site
    @site['site_status']=response.message
    qualify_page(site)
    puts "\n\n"
    @qualification["site_#{@num}"]= @site
   puts @qualification
   @num += 1
   end

end
@qualification
end

def qualify_page(website)
  @usersystem = false
  @goodfit = nil
  @badfit = nil
  page = HTTParty.get(website)
  @page = Nokogiri::HTML(page)
  login
  built_with
  analytics_scripts
  fit
  puts 'This site would be a good fit for a demo!' if @goodfit
  puts 'BAD FIT!' if @badfit
  puts "#{@site}"
end

def header
  @page.xpath('//head')
end

def body
  @page.xpath('//body')
end

def html
  @page.xpath('//html')
end

def login
  USER_SYSTEM.each do |x|
    x = (@page.search "[text()*='"+x+"']")
   if x.to_s.strip.length == 0
   else
   @usersystem = x
   @goodfit = true
  end

end
 # (@usersystem = true) if @page.search "[text()*='"+x+"']"
 #  @goodfit = true
 #  print "This Site has a User System: matched word: " + x + "\n"  if @usersystem
 #  @usersystem = false
 if @usersystem
  print "This Site has a User System\n"
  @site['user_system']=true
else
  print "This Site has no User System\n"
  @site['user_system']=false
end

end

def analytics_scripts
  @analytics = []
  string = html.to_s
  print "GoSquared is on this page\n" if string.include?('_gs')
  @analytics.push('GoSquared') if string.include?('_gs')
  print "Segment is on this page\n" if string.include?('analytics.track' || 'analytics.identify')
  @analytics.push('Segment') if string.include?('analytics.track' || 'analytics.identify')
  print "Google Analytics is on this page\n" if string.include?('ga')
  @analytics.push('Google Analytics') if string.include?('ga')
  print "Google Tag Manager is on this page\n" if string.include?('gtm.start')
  @analytics.push('Google Tag Manager') if string.include?('gtm.start')
  @site['analytics'] = @analytics
end

def chat_scripts
 string = html.to_s
 print "Intercom is on this page\n" if string.include?('intercomSettings')
 @site['chat_scripts']='intercom' if string.include?('intercomSettings')
end


def built_with
  string = header.to_s.downcase
  if  @usersystem && string.include?('wp-content')
     print "This site is built with Wordpress but has a usersystem\n"
     @site['built_with']='Wordpress'
  elsif string.include?('wp-content')
    print "This site is built with Wordpress\n"
    @site['built_with']='Wordpress'
    @badfit = true
  end
  if string.include?('wix')
    print "This site is built with Wix\n"
    @site['built_with']='Wix'
    @badfit = true
  end
  if string.include?('squarespace')
    print "This site is built with SquareSpace\n"
    @site['built_with']='SquareSpace'
    @badfit = true
  end
  if string.include?('rapidweaver')
    print "This site is built with Rapidweaver\n"
    @site['built_with']='Rapidweaver'
    @badfit = true
  end
    if string.include?('tumblr')
    print "This site is built with Rapidweaver\n"
    @site['built_with']='tumblr'
    @badfit = true
  end
end

  def fit
    if  @site['user_system']==true && @site['built_with'].nil?
    @site['fit']='People, Analytics and Chat'
    elsif
    @site['user_system']== true && @site['built_with'] == 'Wordpress'
    @site['fit']='People, Analytics and Chat'
    else
    @site['fit']='Analytics & Chat only'
  end
end

end
