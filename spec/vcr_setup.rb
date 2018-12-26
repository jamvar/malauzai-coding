require 'vcr'

VCR.configure do |c|
	c.cassette_library_dir = 'spec/vcr_cassettes'
	c.hook_into :webmock
	c.ignore_localhost = true
	c.configure_rspec_metadata!
	#c.default_cassette_options = { re_record_interval: (3600 * 24)}
end
