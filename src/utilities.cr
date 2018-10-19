module Utilities
	extend self

	def generate_id
		rand = Random.new
		 # random a slightly higher number than needed to avoid padding issue
		id = rand.base64(10)
		# we want the length of the thingy to be 6 char long
		id = id[0..5]

		# we dont want duplicates, or allow characters like '/' and '+'
		return generate_id if File.exists?("uploads/#{id}")
		return generate_id if /\+|\//.match(id)
		return id
	end

	def find_extension(filename)
		return false unless filename.is_a?(String)

		# start from the back and go backwards to find extension
		# not using .index to avoid shit like hehehe.png.php
		i = filename.size - 1
		j = nil
		while i >= 0
			if filename[i] == '.'
				j = i
				break
			end

			i -= 1
		end

		return false unless j
		return filename[(j + 1)..(filename.size - 1)]
	end

	def illegal_extension?(filename, extensions)
		return false if extensions[:allow_all]

		extension = find_extension(filename)
		return true unless extension
		return !(extensions[:allowed].includes?(extension))
	end
end
