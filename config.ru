$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

use Rack::ShowExceptions

require 'git_http'

config = {
  :project_root => ENV['GIT_PROJECT_ROOT'],
  :upload_pack => true,
  :receive_pack => true,
}

run GitHttp::App.new(config)
