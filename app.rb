require 'sinatra/base'
require 'sinatra/cookies'
require 'sinatra/json'
require File.expand_path '../lib/zimbra_preauth_service.rb', __FILE__

class App < Sinatra::Base
  helpers Sinatra::Cookies

  post '/login' do
    email = params[:email]
    password = params[:password]
    error 401 unless ZimbraPreauthService.valid_credentials?(email, password)
    user = ZimbraPreauthService.user_info email
    json user.marshal_dump
  end

  post '/url' do
    user = ZimbraPreauthService.user_info params[:email]
    json user.marshal_dump
  end

  run! if app_file == $0
end
