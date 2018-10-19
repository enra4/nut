require "./spec_helper.cr"

describe Utilities do
	it "finds extension" do
		Utilities.find_extension("hei.jpg").should(eq("jpg"))
		Utilities.find_extension("mmmMM_ffff.mp4").should(eq("mp4"))
		Utilities.find_extension("asdasg.png.php").should(eq("php"))
		Utilities.find_extension("ja").should(eq(false))
	end

	it "checks for illegal extensions" do
		a = {
			allow_all: true,
			allowed: ["a", "b"]
		}

		Utilities.illegal_extension?("asdas", a).should(eq(false))
		Utilities.illegal_extension?("grim.fak", a).should(eq(false))

		b = {
			allow_all: false,
			allowed: ["png", "mp4"]
		}

		Utilities.illegal_extension?("asdasda", b).should(eq(true))
		Utilities.illegal_extension?("hei.jpg", b).should(eq(true))
		Utilities.illegal_extension?("hei.png", b).should(eq(false))
		Utilities.illegal_extension?("dsfsd_sd.asd.mp4", b).should(eq(false))
	end
end
