require 'sinatra'

enable :sessions

get '/' do
  erb :index, :layout => :layout 
end