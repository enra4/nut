require "kemal"
require "./utilities.cr"

# Kemal.config.env = "production"
Kemal.config.public_folder = "./uploads"
PORT = 3000
SECRET = "" # replace this with your own secret :)
EXTENSIONS = {
	allow_all: false,
	allowed: ["jpg", "png", "mp4", "gif", "webm"]
}

# get "/" do |env|
#	env.redirect("https://enra.me")
# end

post "/upload" do |env|
	if env.request.headers["secret"] != SECRET
		halt(env, status_code: 401, response: "unauthorized")
	end

	id = ""
	extension = ""
	HTTP::FormData.parse(env.request) do |upload|
		if Utilities.illegal_extension?(upload.filename, EXTENSIONS)
			halt(env, status_code: 403, response: "forbidden")
		end

		extension = Utilities.find_extension(upload.filename)
		id = Utilities.generate_id
		File.open("uploads/#{id}.#{extension}", "w") do |file|
			IO.copy(upload.body, file)
		end
	end

	"#{id}.#{extension}"
end

Kemal.run(PORT)
