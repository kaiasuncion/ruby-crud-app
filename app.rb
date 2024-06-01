require 'sinatra'
require 'json'

configure do
  enable :method_override  # Enables method overriding for forms
end
# Routes

# erb:index renders index.erb view template
get '/' do
  erb :index
end

get '/people' do
  file_path = File.join(settings.public_folder, 'people.json')
  
  unless File.exist?(file_path)
    puts "File not found!"
    status 404
    if request.accept.any? { |type| type.downcase.include?("json") }
      content_type :json
      return { error: "File not found" }.to_json
    else
      return erb :not_found  # Serve an HTML error page if one exists
    end
  end

  puts "File found!"
  people_data = File.read(file_path)

  if request.accept.any? { |type| type.downcase.include?("json") }
    content_type :json
    puts "/people is serving JSON"
    people_data  # Return JSON data directly
  else
    puts "/people is serving HTML template"
    @people = JSON.parse(people_data)
    erb :people  # Render an HTML template with the data
  end
end

get '/people/:id' do  # Changed from /people/:name to /people/:id
  file_path = File.join(settings.public_folder, 'people.json')
  people = JSON.parse(File.read(file_path))
  person = people.find { |p| p['id'].to_i == params[:id].to_i }  # Find by ID

  if person
    erb :person, locals: { person: person }
  else
    status 404
    "Person not found"
  end
end

# Receiving and writing people data
post '/people' do
  content_type :json
  begin
    raw_data = request.body.read
    puts "Received data: #{raw_data}"  # Logging incoming raw data
    person = JSON.parse(raw_data)

    # Convert age to an integer if it's a string that represents an integer
    person['age'] = Integer(person['age']) rescue nil

    raise 'Invalid data' unless person['name'] && person['age'].is_a?(Numeric)
    file_path = File.join(settings.public_folder, 'people.json')  # Ensure path is correct
    people = JSON.parse(File.read(file_path))
    new_id = (people.max_by { |p| p['id'] }['id'] rescue 0) + 1
    
    # Create a new hash with 'id' first
    person_with_id_first = { 'id' => new_id }.merge(person)

    people << person_with_id_first
    File.write(file_path, people.to_json)
    person_with_id_first.to_json
  rescue => e
    puts "Error: #{e.message}"  # Detailed error logging
    status 400
    { error: e.message }.to_json
  ensure
    puts "POST /people completed."
  end
end

patch '/people/:id/update_age' do
  file_path = File.join(settings.public_folder, 'people.json')
  people = JSON.parse(File.read(file_path))  # Load the people data

  # Find the person and update their age
  person = people.find { |p| p['id'].to_i == params[:id].to_i }
  if person
    person['age'] = params['age'].to_i  # Update the age
    File.write(file_path, JSON.pretty_generate(people))  # Save the updated data back to file
    redirect "/people/#{params[:id]}"  # Optionally redirect to the person's page or back to the list
  else
    status 404
    erb :not_found  # Serve a 404 not found page or similar
  end
end

# Delete user
delete '/people/:id' do
  file_path = File.join(settings.public_folder, 'people.json')
  people = JSON.parse(File.read(file_path))

  people.reject! { |person| person['id'].to_i == params[:id].to_i }
  File.write(file_path, JSON.pretty_generate(people))

  redirect '/'  # Redirect to the home page or list page after deletion
end