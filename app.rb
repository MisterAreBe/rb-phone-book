require 'sinatra'
require 'mysql2'
require 'aws-sdk'


client = Mysql2::Client.new(:username => ENV['RDS_USERNAME'], :password => ENV['RDS_PASSWORD'], :host => ENV['RDS_HOSTNAME'], :port => ENV['RDS_PORT'], :database => ENV['RDS_DB_NAME'], :sock => '/tmp/mysql.sock')

load 'local_ENV.rb' if File.exist?('local_ENV.rb')
enable :sessions

get '/' do
  'Hello World!'
  # erb :index, :layout => :layout 
end

post '/add' do

end