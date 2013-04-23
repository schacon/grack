require 'rubygems'
require 'rack'
require 'rack/test'
require 'test/unit'
require 'mocha/setup'
require 'digest/sha1'

require './lib/git_http'
require './lib/git_adapter'
require 'pp'

class GitHttpTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def example
    File.join(File.expand_path(File.dirname(__FILE__)),'example')
  end
  
  def test_repo
    File.join(example, 'test_repo')
  end

  def app
    config = {
      :project_root => example,
      :upload_pack => true,
      :receive_pack => true,
      :adapter => GitAdapter,
      :git_path => 'git'
    }
    GitHttp::App.new(config)
  end

  def test_upload_pack_advertisement
    get "/test_repo/info/refs?service=git-upload-pack"
    assert_equal 200, r.status
    assert_equal "application/x-git-upload-pack-advertisement", r.headers["Content-Type"]
    assert_equal "001e# service=git-upload-pack", r.body.split("\n").first
    assert_match 'multi_ack_detailed', r.body
  end

  def test_no_access_wrong_content_type_up
    post "/test_repo/git-upload-pack"
    assert_equal 403, r.status
  end

  def test_no_access_wrong_content_type_rp
    post "/test_repo/git-receive-pack"
    assert_equal 403, r.status
  end

  def test_no_access_wrong_method_rcp
    get "/test_repo/git-upload-pack"
    assert_equal 400, r.status
  end

  def test_no_access_wrong_command_rcp
    post "/test_repo/git-upload-packfile"
    assert_equal 404, r.status
  end

  def test_no_access_wrong_path_rcp
    post "/example-wrong/git-upload-pack"
    assert_equal 404, r.status
  end

  def test_upload_pack_rpc
    IO.stubs(:popen).returns(MockProcess.new)
    post "/test_repo/git-upload-pack", {}, {"CONTENT_TYPE" => "application/x-git-upload-pack-request"}
    assert_equal 200, r.status
    assert_equal "application/x-git-upload-pack-result", r.headers["Content-Type"]
  end

  def test_receive_pack_advertisement
    get "/test_repo/info/refs?service=git-receive-pack"
    assert_equal 200, r.status
    assert_equal "application/x-git-receive-pack-advertisement", r.headers["Content-Type"]
    assert_equal "001f# service=git-receive-pack", r.body.split("\n").first
    assert_match 'report-status', r.body
    assert_match 'delete-refs', r.body
    assert_match 'ofs-delta', r.body
  end

  def test_recieve_pack_rpc
    IO.stubs(:popen).yields(MockProcess.new)
    post "/test_repo/git-receive-pack", {}, {"CONTENT_TYPE" => "application/x-git-receive-pack-request"}
    assert_equal 200, r.status
    assert_equal "application/x-git-receive-pack-result", r.headers["Content-Type"]
  end

  def test_info_refs_dumb
    get "/test_repo/.git/info/refs"
    assert_equal 200, r.status
  end

  def test_info_packs
    get "/test_repo/.git/objects/info/packs"
    assert_equal 200, r.status
    assert_match /P pack-(.*?).pack/, r.body
  end

  def test_loose_objects
    path, content = write_test_objects
    get "/test_repo/.git/objects/#{path}"
    assert_equal 200, r.status
    assert_equal content, r.body
    remove_test_objects
  end

  def test_pack_file
    path, content = write_test_objects
    get "/test_repo/.git/objects/pack/pack-#{content}.pack"
    assert_equal 200, r.status
    assert_equal content, r.body
    remove_test_objects
  end

  def test_index_file
    path, content = write_test_objects
    get "/test_repo/.git/objects/pack/pack-#{content}.idx"
    assert_equal 200, r.status
    assert_equal content, r.body
    remove_test_objects
  end

  def test_text_file
    get "/test_repo/.git/HEAD"
    assert_equal 200, r.status
    assert_equal 23, r.body.size
  end

  def test_no_size_avail
    File.stubs('size?').returns(false)
    get "/test_repo/.git/HEAD"
    assert_equal 200, r.status
    assert_equal 23, r.body.size
  end

  def test_config_upload_pack_off
    a1 = app
    a1.set_config_setting(:upload_pack, false)
    session = Rack::Test::Session.new(a1)
    session.get "/test_repo/info/refs?service=git-upload-pack"
    assert_equal 404, session.last_response.status
  end

  def test_config_receive_pack_off
    a1 = app
    a1.set_config_setting(:receive_pack, false)
    session = Rack::Test::Session.new(a1)
    session.get "/test_repo/info/refs?service=git-receive-pack"
    assert_equal 404, session.last_response.status
  end

  def test_config_bad_service
    get "/test_repo/info/refs?service=git-receive-packfile"
    assert_equal 404, r.status
  end

  def test_get_config_setting_receive_pack
    app1 = GitHttp::App.new({:project_root => example, :adapter=>GitAdapter})
    session = Rack::Test::Session.new(app1)
    abs_path = test_repo

    app1.git.stubs(:get_config_setting).with(abs_path,'http.receivepack').returns('')
    session.get "/test_repo/info/refs?service=git-receive-pack"
    assert_equal 404, session.last_response.status

    app1.git.stubs(:get_config_setting).with(abs_path,'http.receivepack').returns('true')
    session.get "/test_repo/info/refs?service=git-receive-pack"
    assert_equal 200, session.last_response.status

    app1.git.stubs(:get_config_setting).with(abs_path,'http.receivepack').returns('false')
    session.get "/test_repo/info/refs?service=git-receive-pack"
    assert_equal 404, session.last_response.status
  end

  def test_get_config_setting_upload_pack
    app1 = GitHttp::App.new({:project_root => example, :adapter=>GitAdapter})
    session = Rack::Test::Session.new(app1)
    abs_path = test_repo

    app1.git.stubs(:get_config_setting).with(abs_path,'http.uploadpack').returns('')
    session.get "/test_repo/info/refs?service=git-upload-pack"
    assert_equal 200, session.last_response.status

    app1.git.stubs(:get_config_setting).with(abs_path,'http.uploadpack').returns('true')
    session.get "/test_repo/info/refs?service=git-upload-pack"
    assert_equal 200, session.last_response.status

    app1.git.stubs(:get_config_setting).with(abs_path,'http.uploadpack').returns('false')
    session.get "/test_repo/info/refs?service=git-upload-pack"
    assert_equal 404, session.last_response.status
  end

  private

  def r
    last_response
  end

  def write_test_objects
    content = Digest::SHA1.hexdigest('gitrocks')
    base = File.join(test_repo, '.git', 'objects')    
    obj = File.join(base, '20')
    Dir.mkdir(obj) rescue nil
    file = File.join(obj, content[0, 38])
    File.open(file, 'w') { |f| f.write(content) }
    pack = File.join(base, 'pack', "pack-#{content}.pack")
    File.open(pack, 'w') { |f| f.write(content) }
    idx = File.join(base, 'pack', "pack-#{content}.idx")
    File.open(idx, 'w') { |f| f.write(content) }
    ["20/#{content[0,38]}", content]
  end

  def remove_test_objects
    content = Digest::SHA1.hexdigest('gitrocks')
    base = File.join(test_repo, '.git', 'objects')    
    obj = File.join(base, '20')
    file = File.join(obj, content[0, 38])
    pack = File.join(base, 'pack', "pack-#{content}.pack")
    idx = File.join(base, 'pack', "pack-#{content}.idx")
    File.unlink(file)
    File.unlink(pack)
    File.unlink(idx)
  end

end

class MockProcess

  def initialize
    @counter = 0
  end

  def write(data)
  end

  def read(data)
  end

  def eof?
    @counter += 1
    @counter > 1 ? true : false
  end

end
