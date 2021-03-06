require 'sinatra'
require 'mysql2'
require 'aws-sdk'
require 'bcrypt'
require 'sanitize'

load 'local_ENV.rb' if File.exist?('local_ENV.rb')
enable :sessions

client = Mysql2::Client.new(:username => ENV['RDS_USERNAME'], :password => ENV['RDS_PASSWORD'], :host => ENV['RDS_HOSTNAME'], :port => ENV['RDS_PORT'], :database => ENV['RDS_DB_NAME'], :sock => '/tmp/mysql.sock')

get '/' do
  error = session[:error] || ""
  if error.include?("-")
    msg = error.split("-")
    error_msg1 = msg[0]
    error_msg2 = msg[1]
  else
    error_msg1 = error
    error_msg2 = ""
  end
  erb :login, :layout => :layout, locals: {error_msg1: error_msg1, error_msg2: error_msg2}
end

post '/login' do
  username = params[:username] || ""
  password = params[:password] || ""
  checked = []
  kept_name = []
  correct_pass = []

  # cleaning user input
  username = Sanitize.clean(username); username = client.escape(username)
  password = Sanitize.clean(password); password = client.escape(password)

  # gathering user info
  validation = client.query("SELECT `password` FROM `users` WHERE `user_name` = '#{username}'")
  validation.each do |v|
    correct_pass << v['password']
  end
  checkem = client.query("SELECT * FROM `users` WHERE `user_name` = '#{username}' AND `password` = '#{correct_pass.join("")}'")
  checkem.each do |v|
    checked << v['user_id']
  end

  # checking validation
  if checked[0].is_a?(Integer)
    if checked[0] > 0
      session[:user_name] = username
      redirect '/list'
    end
  else
    session[:error] = "Incorrect Username or Password.-Try Again, or Create New User."
    redirect '/'
  end
end

post '/new_user' do
  username = params[:username] || ""
  password = params[:password] || ""
  new_password = params[:validate_password] || ""


  #cleaning user input
  username = Sanitize.clean(username); username = client.escape(username)
  password = Sanitize.clean(password); password = client.escape(password)
  new_password = Sanitize.clean(new_password); new_password = client.escape(new_password)

  # checking passwords match
  unless password == new_password
    session[:error] = "Passwords do not match!"
    redirect '/'
  end

  # checking username isn't taken
  unique_user = client.query("SELECT `user_name` FROM users")
  unique_user.each do |v|
    if v.has_value?(username)
      session[:error] = "Username already taken.-Please select a new one."
      redirect '/'
    end
  end

  # creating new user
  secure_password = BCrypt::Password.create(password)
  client.query("INSERT INTO `users`(user_name, password)
  VALUES('#{username}', '#{secure_password}')")
  session[:error] = "You made a new account!-Now just login with it."
  redirect '/'
end

get '/list' do
  user_name = session[:user_name] || ""
  user_name = Sanitize.clean(user_name)
  user_name = client.escape(user_name)
  contact_list = []
  contact_record = []
  # fetching user data
  resultSet = client.query("SELECT * FROM `contacts` WHERE `user_name` = '#{user_name}'")
  resultSet.each do |row|
    contact_list << [[row['First_Name']], [row['Last_Name']], [row['Street']], [row['City']], [row['State']], [row['Zip']], [row['Phone_Number']]]
    contact_record << row['id']
  end
  # setting y index of page
  scroll = session[:scroll] || "0"
  user_name.tr!("\\", "")
  erb :index, :layout => :layout, locals: {contact_list: contact_list, contact_record: contact_record,scroll: scroll, user_name: user_name}
end

post '/add' do
  temp_hash = {
  user_name: session[:user_name] || "",
  first_name: params[:f_name] || "",
  last_name: params[:l_name] || "",
  street: params[:street] || "",
  city: params[:city] || "",
  state: params[:state] || "",
  zip: params[:zip] || "",
  phone_number: params[:p_num] || ""
  }
puts temp_hash
  # cleaning and escaping user input
  temp_hash.each do |key,value|
    temp_hash[key] = Sanitize.clean(value)
    temp_hash[key] = client.escape(value)
  end
puts temp_hash
  # adding contact to db
  client.query("INSERT INTO `contacts`(user_name, First_Name, Last_Name, Street, City, State, Zip, Phone_Number)
  VALUES('#{temp_hash[:user_name]}', '#{temp_hash[:first_name]}', '#{temp_hash[:last_name]}', '#{temp_hash[:street]}', '#{temp_hash[:city]}', '#{temp_hash[:state]}', '#{temp_hash[:zip]}', '#{temp_hash[:phone_number]}')")
  redirect '/list'
end

post '/update' do
  user_name = session[:user_name] || ""
  row_col = params[:contacts] || ""
  update = params[:new_info] || ""
  scroll = params[:scroll] || ""
  
  # escaping str
  update = Sanitize.clean(update)
  update = client.escape(update)
  user_name = Sanitize.clean(user_name)
  user_name = client.escape(user_name)
  # finding what it being updated
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

  # updating db
  client.query("UPDATE `contacts` SET `#{column}`='#{update}' WHERE `id`='#{row}' AND `user_name`='#{user_name}'")
  
  session[:scroll] = scroll
  redirect '/list'
end

post '/delete_contact' do
  delete_contact = params[:row]
  client.query("DELETE FROM `contacts` WHERE `id`='#{delete_contact}'")
  redirect '/list'
end