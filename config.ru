ENV['RACK_ENV'] = 'development'

$LOAD_PATH << '.'
require 'app'

run PeoplemeterStats
