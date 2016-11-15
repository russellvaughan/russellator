require 'qualifier.rb'
class RussellatorController < ApplicationController 

def index
@params = session[:response]  
end

def search
qs = Qualifier.new params[:q]
qs.qualify
response = qs.qualify_user_sites
session[:response] = response
redirect_to '/index'
end


end