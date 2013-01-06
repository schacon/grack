$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/lib')

use Rack::ShowExceptions

require 'git_http'
require 'git_controller'
require 'rjgit_controller'

config = {
  :project_root => "./",
  :controller => RJGitController,
  #:controller => GitController,
  #:git_path => '/usr/bin/git',
  :upload_pack => true,
  :receive_pack => true,
}

run GitHttp::App.new(config)
