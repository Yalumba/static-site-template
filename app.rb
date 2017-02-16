require 'dotenv'
require 'bundler'

Dotenv.load
Bundler.require

require 'sinatra/asset_pipeline'
require 'sinatra/content_for'

require './lib/helpers'

class App < Sinatra::Base
  helpers Sinatra::ContentFor
  helpers Statique::Helpers

  register Sinatra::AssetPipeline
  assets_precompile << ['favicon.ico']

  configure do
    set :haml, :layout => :'layouts/default'
    unless (app_name = ENV["HEROKU_APP_NAME"]).nil?
      require 'heroku-api'

      heroku  = Heroku::API.new(:api_key => ENV["HEROKU_API_KEY"])
      release = heroku.get_releases(app_name).body.last

      ENV["HEROKU_RELEASE_NAME"] = release["name"]
    end
  end

  configure :development do
    require 'pry'
    require "better_errors"
    use BetterErrors::Middleware
    BetterErrors.application_root = __dir__
    ENV["HEROKU_RELEASE_NAME"] = 'v999'
  end

  configure :production do
    # Purge KeyCDN on boot:
    if ENV["KEYCDN_PURGE_ON_BOOT"] == 'true'
      keycdn = KeyCDN::Client.new(ENV["KEYCDN_API_KEY"])
      keycdn.get("zones/purge/#{ENV["KEYCDN_ZONE_ID"]}.json")
    end
  end

  before do
    cache_control :public, max_age: 604800 #1 week
    response.headers['Version'] = ENV["HEROKU_RELEASE_NAME"]
    @site_name = "Statique Sité!"
  end

  get '/' do
    haml :home
  end

  get '/:slug' do
    begin
      haml :"pages/#{params[:slug]}"
    rescue Errno::ENOENT
      pass
    end
  end 
    
  not_found do
    haml :'errors/not_found'
  end

end