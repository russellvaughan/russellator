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
    @user_sites.length.times do |num|
      @site = instance_variable_set("@site_#{num}", Hash.new)
      begin
        response = HTTParty.get(@user_sites[num])
      rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Errno::ECONNREFUSED,
        Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, Errno::ETIMEDOUT, URI::InvalidURIError, OpenSSL::SSL::SSLError => error
        @site['url']=@user_sites[num]
        puts "Site does not load: #{error}"
        @site['site_status']=error
        @qualification["site_#{num}"]= @site
        puts @qualification
      end
      puts @user_sites[num]
      if response
        @site['url']=@user_sites[num]
        @site['site_status']=response.message
        qualify_page(@user_sites[num]) if response.headers['content-type'].include?('html')
        @qualification["site_#{@num}"]= @site
        puts @qualification
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
 if @usersystem
  @site['user_system']=true
else
  @site['user_system']=false
end

end

def analytics_scripts
  @analytics = []
  string = html.to_s
  @analytics.push('GoSquared') if string.include?('_gs')
  @analytics.push('Segment') if string.include?('analytics.track' || 'analytics.identify')
  @analytics.push('Google Analytics') if string.include?('ga')
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
   @site['built_with']='Wordpress'
 elsif string.include?('wp-content')
  @site['built_with']='Wordpress'
  @badfit = true
end
if string.include?('wix')
  @site['built_with']='Wix'
  @badfit = true
end
if string.include?('squarespace')
  @site['built_with']='SquareSpace'
  @badfit = true
end
if string.include?('rapidweaver')
  @site['built_with']='Rapidweaver'
  @badfit = true
end
if string.include?('tumblr')
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
