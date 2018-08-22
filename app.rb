require 'sinatra'
require 'mysql2'
require 'aws-sdk'

load 'local_ENV.rb' if File.exist?('local_ENV.rb')
enable :sessions

client = Mysql2::Client.new(:username => ENV['RDS_USERNAME'], :password => ENV['RDS_PASSWORD'], :host => ENV['RDS_HOSTNAME'], :port => ENV['RDS_PORT'], :database => ENV['RDS_DB_NAME'], :sock => '/tmp/mysql.sock')
results = client.query("SELECT * FROM contacts")



get '/' do
  erb :login, :layout => :layout
end

post '/contacts' do
  redirect '/list'
end

get '/list' do
  resultSet = client.query('SELECT * FROM contacts')
  contact_list = []
  resultSet.each do |row|
    contact_list << [[row['First_Name']], [row['Last_Name']], [row['Street']], [row['City']], [row['State']], [row['Zip']], [row['Phone_Number']]]
  end

  erb :index, :layout => :layout, locals: {contact_list: contact_list}
end

post '/add' do
  first_name = params[:f_name]
  last_name = params[:l_name]
  street = params[:street]
  city = params[:city]
  state = params[:state]
  zip = params[:zip]
  phone_number = params[:p_num]
  row_col = params[:contacts]
  update = params[:new_info]

  unless row_col == ""
    temp = row_col.split("-")
    row = temp[0]
    col = temp[1].to_i
    column = ""
    case col
    when 1
      column = "First_Name"
    when 2
      column = "Last_Name"
    when 3
      column = "Street"
    when 4
      column = "City"
    when 5
      column = "State"
    when 6
      column = "Zip"
    when 7
      column = "Phone_Number"
    end

    client.query("UPDATE `contacts` SET `#{column}`='#{update}' WHERE `id`='#{row}'")
  else
    client.query("INSERT INTO contacts(First_Name, Last_Name, Street, City, State, Zip, Phone_Number)
    VALUES('#{first_name}', '#{last_name}', '#{street}', '#{city}', '#{state}', '#{zip}', '#{phone_number}')")
  end
  redirect '/list'
end