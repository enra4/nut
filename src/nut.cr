require "kemal"
require "reeelog"
require "./utilities.cr"

# you might have to set headers in nginx or something if u want ip addresses in logs
# Kemal.config.env = "production"
Kemal.config.public_folder = "./uploads"
logging false # disable kemal logging
log = Reeelog.start("nut.log")
PORT = 3000
SECRET = "" # replace this with your own secret :)
EXTENSIONS = {
	allow_all: false,
	allowed: ["jpg", "png", "mp4", "gif", "webm"]
}

get "/" do |env|
	env.redirect("https://github.com/enra4/nut")
end

post "/upload" do |env|
	ip = "someone"
	if env.request.headers.has_key?("X-Forwarded-For")
		ip = env.request.headers["X-Forwarded-For"]
	end

	if env.request.headers["secret"] != SECRET
		log.warn("upload", "#{ip} tried to upload with wrong secret")
		halt(env, status_code: 401, response: "unauthorized")
	end

	id = ""
	extension = ""
	HTTP::FormData.parse(env.request) do |upload|
		if Utilities.illegal_extension?(upload.filename, EXTENSIONS)
			log.warn("upload", "#{ip} tried to upload file with illegal extension")
			halt(env, status_code: 403, response: "forbidden")
		else
			extension = Utilities.find_extension(upload.filename)
			id = Utilities.generate_id
			begin
				File.open("uploads/#{id}.#{extension}", "w") do |file|
					IO.copy(upload.body, file)
				end

				log.success("upload", "#{ip} uploaded to uploads/#{id}.#{extension}")
				halt(env, status_code: 200, response: "#{id}.#{extension}")
			rescue error
				log.error("upload", "error writing to file (error from #{ip})")
				halt(env, status_code: 500, response: "something broke")
			end
		end
	end
end

log.info("app", "server is running on port #{PORT.to_s}")
Kemal.run(PORT)
