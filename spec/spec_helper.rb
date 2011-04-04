require 'bundler'
Bundler.setup(:default, :test)

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'rspec/autorun'
require 'vcr'
require 'extraction'
require 'stringio'
require 'fileutils'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

def tmp_dir
  File.expand_path("../tmp", __FILE__)
end

def create_tmp_dir
  FileUtils.rm_r(tmp_dir) if File.exist?(tmp_dir)
  FileUtils.mkdir_p(tmp_dir)
end

def delete_tmp_dir
  FileUtils.rm_r(tmp_dir)
end

VCR.config do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.stub_with :fakeweb #:typhoeus, :fakeweb, or :webmock
  c.default_cassette_options = { :record => :new_episodes }
end

RSpec.configure do |config|
  config.extend VCR::RSpec::Macros
  #config.mock_with :mocha
end

