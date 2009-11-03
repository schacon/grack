require 'rubygems'
require 'rack'
require "rack/test"
require 'test/unit'

require 'lib/git_http'

class GitHttpTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    GitHttp::App.new(false)
  end

  # def config_project_root
  # def config_git_path
  # def config_upload_path_on
  # def config_upload_path_off
  # def config_upload_path_setting_on
  # def config_upload_path_setting_off
  # def test_upload_pack_advertisement
  # def test_upload_pack_rpc
  # def test_receive_pack_advertisement
  # def test_receive_pack_rpc
  # def test_dumb_urls
  # def test_method_not_allowed
  # def test_not_a_command
  # def test_not_git_dir
  
  def test_redirect_logged_in_users_to_dashboard
    get "/"
    assert_equal "http://example.org/redirected", last_request.url
    assert last_response.ok?
  end

end