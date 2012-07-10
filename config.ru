$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/lib')

use Rack::ShowExceptions

require 'git_http'

config = {
  :project_root => "/Users/gabonsky/Projects/OpenSource/grack/repos",
  :git_path => '/opt/local/bin/git',
  :upload_pack => true,
  :receive_pack => true,
  :git_auto_init => true,
}

run GitHttp::App.new(config)
