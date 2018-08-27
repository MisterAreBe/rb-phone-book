require 'sinatra'
require 'mysql2'
require 'aws-sdk'
require 'bcrypt'

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

post '/contacts' do
  results = client.query("SELECT * FROM users")
  username = params[:username]
  password = params[:password]
  new_password = params[:validate_password] || ""
  what_to_do = params[:what_do]

  if what_to_do == "0"
    correct_pass = []
    validation = client.query("SELECT `password` FROM users WHERE `user_name` = '#{username}'")
    validation.each do |v|
      correct_pass << v['password']
      puts "this is correct_pass #{correct_pass}"
    end
    checked = []
    kept_name = []
    checkem = client.query("SELECT * FROM `users` WHERE `user_name` = '#{username}' AND `password` = '#{correct_pass.join("")}'")
    checkem.each do |v|
      checked << v['user_id']
      kept_name << v['user_name']
      puts "this is checked #{checked} and this is checkem #{v}"
    end
    if checked[0].is_a?(Integer)
      if checked[0] > 0
        session[:user_name] = kept_name.join("")
        redirect '/list'
      end
    else
      session[:error] = "Incorrect Username or Password.-Try Again, or Create New User."
      redirect '/'
    end
  elsif what_to_do == "1"
    unless password == new_password
      session[:error] = "Passwords do not match!"
      redirect '/'
    end
    unique_user = client.query("SELECT `user_name` FROM users")
    unique_user.each do |v|
      if username == v
        session[:error] = "Username already taken.-Please select a new one."
        redirect '/'
      end
    end
    secure_password = BCrypt::Password.create(password)
    client.query("INSERT INTO `users`(user_name, password)
    VALUES('#{username}', '#{secure_password}')")
    session[:error] = "You made a new account!-Now just login with it."
    redirect '/'
  end
end

get '/list' do
  user_name = session[:user_name]
  resultSet = client.query("SELECT * FROM contacts WHERE `user_name` = '#{user_name}'")
  contact_list = []
  contact_record = []
  resultSet.each do |row|
    contact_list << [[row['First_Name']], [row['Last_Name']], [row['Street']], [row['City']], [row['State']], [row['Zip']], [row['Phone_Number']]]
    contact_record << row['id']
  end
  scroll = session[:scroll] || "0"
  erb :index, :layout => :layout, locals: {contact_list: contact_list, contact_record: contact_record,scroll: scroll, user_name: user_name}
end

post '/add' do
  delete_contact = params[:delete_contact] || ""
  user_name = params[:user_name] || ""
  first_name = params[:f_name] || ""
  last_name = params[:l_name] || ""
  street = params[:street] || ""
  city = params[:city] || ""
  state = params[:state] || ""
  zip = params[:zip] || ""
  phone_number = params[:p_num] || ""
  row_col = params[:contacts]
  update = params[:new_info]
  scroll = params[:scroll]
  temp_arr = [user_name, first_name, last_name, street, city, state, zip, phone_number]
  good = 8
  temp_arr.each do |v|
    if v == ""
      good -= 1
    end
  end
  if delete_contact.to_i > 0
    client.query("DELETE FROM `contacts` WHERE `id`='#{delete_contact}'")
  elsif row_col != ""
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

    client.query("UPDATE `contacts` SET `#{column}`='#{update}' WHERE `id`='#{row}' AND `user_name`='#{user_name}'")
  elsif good == 8
    client.query("INSERT INTO `contacts`(user_name, First_Name, Last_Name, Street, City, State, Zip, Phone_Number)
    VALUES('#{user_name}', '#{first_name}', '#{last_name}', '#{street}', '#{city}', '#{state}', '#{zip}', '#{phone_number}')")
  end
  session[:scroll] = scroll
  session[:user_name] = user_name
  redirect '/list'
end