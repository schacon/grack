$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/lib')

use Rack::ShowExceptions

require 'lib/git_http'

config = {
  :project_root => "/opt",
  :git_path => '/usr/local/libexec/git-core/git',
  :server_prefix => 'git/',
  :upload_pack => true,
  :receive_pack => true,
}

run GitHttp::App.new(config)
