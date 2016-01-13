require 'sinatra'
require 'json'
require 'open-uri'


  require 'pry'


get '/' do
	"Welcome to the Manifest receiver"	
end

get '/receive' do

	receivedurl = params[:url] 
	
	begin
		new_file = open(receivedurl)
		if new_file.status[0] = "200"
			new_hash = JSON.parse(new_file.read)
		else
			
			return "Update failed"
		end
	rescue OpenURI::HTTPError => ex
		
		return "Url not found"
	end

	# run tests on json file
	if new_hash["rangelist"]["token"] = 'this is valid' 
		manifesturl = new_hash["rangelist"]["manifests"][0]
		type = new_hash["rangelist"]["@type"]
		
		result_hash = {manifest: 
			{
				manifesturl: manifesturl,
				receivedurl: receivedurl,
				type: type
			}}

		current_file = open("entries.json").read

		current_hash = JSON.parse(current_file)
		
		current_hash["wrapper"] << result_hash

		File.open("entries.json", "w") do |file|
			file.write(JSON.pretty_generate(current_hash))
		end
		"Update complete"
	else
		"Update failed"
	end

end

get '/result' do 
	content_type :json 
  send_file "entries.json"
end
	
