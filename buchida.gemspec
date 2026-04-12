Gem::Specification.new do |s|
	s.name        = "buchida"
	s.version     = "0.1.2"
	s.summary     = "Official Ruby SDK for buchida email API"
	s.description = "Official Ruby SDK for the buchida email API. Send transactional and marketing emails via buchida's REST API with native CJK template support."
	s.authors     = ["buchida"]
	s.email       = "hello@buchida.com"
	s.homepage    = "https://github.com/Vyblor/buchida-ruby"
	s.license     = "MIT"

	s.required_ruby_version = ">= 3.2.0"

	s.files = Dir["lib/**/*.rb"]

	s.add_development_dependency "minitest", "~> 5.0"
	s.add_development_dependency "webmock", "~> 3.0"
end
