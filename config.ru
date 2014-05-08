require 'rubygems' 
require 'bundler'  

Bundler.require
Dotenv.load

require './app'
require './routes'
require './helpers'

run Yabis.new