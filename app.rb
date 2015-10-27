require 'sinatra/base'
require 'json'
require 'zlib'
require 'tilt'
require 'slim'

STATS_PATH = File.join(File.dirname(__FILE__), "stats")

class PeoplemeterStats < Sinatra::Base
  before do
    content_type :html
  end

  configure :test do
    enable :logging
  end

  configure :production do
    disable :logging
  end

  configure :development, :test do
    get '/help' do
      "Just a test\n"
    end
  end

  get '/' do
    slim :index
  end

  get '/:sn' do
    serial_number = params[:sn]
    halt 404, "Wrong serial number" unless File.directory? File.join(STATS_PATH, serial_number)
    #template = Tilt.new('views/stb.slim')
    #template.render self, { :serial_number => serial_number }
    slim :stb, :locals => { :serial_number => serial_number, :id => params[:id] }
  end
end
