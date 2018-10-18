require "kemal"

# Kemal.config.env = "production"
PORT = 3000
SECRET = ""

def generate_id
	rand = Random.new
	 # random a slightly higher number than needed to avoid padding issue
	string = rand.base64(10)
	# we want the length of the thingy to be 6 char long
	string = string[0..5]

	# we dont want duplicates, or allow characters like '/' and '+'
	return generate_id if File.exists?("public/#{string}")
	return generate_id if /\+|\//.match(string)
	return string
end

# get "/" do |env|
#	env.redirect("https://enra.me")
# end

post "/upload" do |env|
	if env.request.headers["secret"] != SECRET
		halt(env, status_code: 403, response: "unauthorized")
	end

	id = ""
	extension = ""
	HTTP::FormData.parse(env.request) do |upload|
		filename = upload.filename
		if filename.is_a?(String)
			i = filename.index(".")
			j = filename.size - 1
			extension = filename[i..j] if i.is_a?(Int32)
		end

		id = generate_id
		File.open("public/#{id}#{extension}", "w") do |file|
			IO.copy(upload.body, file)
		end
	end

	id + extension
end

Kemal.run(PORT)
