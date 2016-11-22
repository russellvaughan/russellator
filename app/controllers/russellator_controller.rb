require 'qualifier.rb'
class RussellatorController < ApplicationController
after_filter :clear_session, :only => :index

def index
@params = session[:response]
end

def search
qs = Qualifier.new params[:id]
qs.qualify
response = qs.qualify_user_sites
session[:response] = response
redirect_to '/index'
end

def clear_session
session[:response] = nil
end

end
