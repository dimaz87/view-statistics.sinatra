require 'sinatra/base'
require 'json'
require 'zlib'
require 'tilt'
require 'time'
require 'slim'

STATS_PATH = ENV['STATS_PATH'] || File.join(File.dirname(__FILE__), "stats")

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
    total_reports = 0
    last_timestamp = nil
    last_serial = nil
    stbs = Hash.new

    dirs = Dir.glob(File.join(STATS_PATH, "*")).select { |path| File.directory? path }.sort
    dirs.each do |path|
      serial_number = File.basename path
      entries = Dir.entries(path).sort.select { |path2| File.basename(path2) =~ /\d{8}\-\d{6}\.\d{3}$/ }
      if entries.size
        total_reports += entries.size
        stbs[serial_number] = entries.size
        last_timestamp, last_serial = entries.last, serial_number if (!last_timestamp || entries.last > last_timestamp)
      end
    end

    slim :index, :locals => { :stbs => stbs, :total_reports => total_reports, :last_timestamp => last_timestamp, :last_serial => last_serial }
  end

  get '/:sn' do
    serial_number = params[:sn]
    halt 404, "Wrong serial number" unless File.directory? File.join(STATS_PATH, serial_number)
    #template = Tilt.new('views/stb.slim')
    #template.render self, { :serial_number => serial_number }
    slim :stb, :locals => { :serial_number => serial_number, :id => params[:id] }
  end
end
