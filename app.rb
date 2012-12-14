require 'json'
require 'omniauth'
require 'omniauth-instagram'
require 'partial_helper'
require 'secrets'
require 'sinatra/base'

class App < Sinatra::Base
  helpers Sinatra::PartialHelper

  set :static, true
  set :public_folder, File.dirname(__FILE__) + '/public'

  use Rack::Session::Cookie

  use OmniAuth::Builder do
    provider :instagram, IG_CLIENT_ID, IG_CLIENT_SECRET
  end

  get '/' do
    redirect to('/login') unless session_is_valid?
    haml :index
  end

  get '/login' do
    redirect to('/') if session_is_valid?
    @authorize_url = "/auth/instagram"
    haml :login
  end

  get '/logout' do
    session[:uid] = nil
    redirect to('/login')
  end

  get '/auth/instagram/callback' do
    session[:uid] = auth_hash[:uid]
    redirect to('/')
  end

  get '/about' do
    haml :about
  end

  not_found do
    redirect to('/')
  end

  protected

    def auth_hash
      request.env['omniauth.auth']
    end

    def session_is_valid?
      !!session[:uid]
    end
end
