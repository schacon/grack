#! /usr/bin/env ruby
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'grack'
require 'git_adapter'

config = {
  :project_root => "/opt",
  :upload_pack => true,
  :receive_pack => false,
}
Rack::Handler::FastCGI.run(Grack::App.new(config))