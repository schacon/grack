require 'rubygems'
require 'test/unit'
require 'mocha/setup'
require "stringio"

require './lib/rjgit_controller'


class RJGitControllerTest < Test::Unit::TestCase

  NON_EXISTENT_REPOSITORY_AD = "00710000000000000000000000000000000000000000 capabilities^{}\000 side-band-64k delete-refs report-status ofs-delta \n0000"
  
  def example
    File.expand_path(File.join(File.dirname(__FILE__),'example'))
  end

  def setup
    @test_git = RJGitController.new
  end
  
  def repo_test
    assert_equal true, @test_git.repo.is_a?(RJGit::Repo)
  end
    
  def test_service_command
    assert_equal nil, @test_git.service_command(:no_rpc, example, {:msg => "0000\n"})
  end
  
  def test_upload_pack
    assert_equal "0000", @test_git.upload_pack(File.join('/','norepository'), {:advertise_refs=> true})
    RJGit::RJGitUploadPack.any_instance.stubs(:process).returns(StringIO.new("ran RJGitUploadPack.process"),nil)
    assert_equal "ran RJGitUploadPack.process", @test_git.upload_pack(example, {:msg => "0000\n"})
    RJGit::RJGitUploadPack.any_instance.stubs(:process).returns(StringIO.new("ran RJGitUploadPack.process"),nil)
    @test_git.upload_pack(example, {:msg => "0000\n"}) do |pipe|
      assert_equal "ran RJGitUploadPack.process", pipe.read
    end
    RJGit::RJGitUploadPack.any_instance.stubs(:advertise_refs).returns("refs advertised")
    assert_equal "refs advertised", @test_git.upload_pack(example, {:advertise_refs => true})
  end
  
  def test_receive_pack
    assert_equal NON_EXISTENT_REPOSITORY_AD, @test_git.receive_pack(File.join('/','norepository'), {:advertise_refs=> true})
    RJGit::RJGitReceivePack.any_instance.stubs(:process).returns(StringIO.new("ran RJGitReceivePack.process"),nil)
    assert_equal "ran RJGitReceivePack.process", @test_git.receive_pack(example, {:msg => "0000\n"})
    RJGit::RJGitReceivePack.any_instance.stubs(:process).returns(StringIO.new("ran RJGitReceivePack.process"),nil)
    @test_git.receive_pack(example, {:msg => "0000\n"}) do |pipe|
      assert_equal "ran RJGitReceivePack.process", pipe.read
    end
    RJGit::RJGitReceivePack.any_instance.stubs(:advertise_refs).returns("refs advertised")
    assert_equal "refs advertised", @test_git.receive_pack(example, {:advertise_refs => true})
  end
  
  def test_update_server
    RJGit::Repo.any_instance.stubs(:update_server_info).returns(true)
    assert_equal true, @test_git.update_server_info(example)
  end
  
  def test_get_config_setting
    RJGit::Repo.any_instance.stubs(:config).raises(RuntimeError)
    assert_equal nil, @test_git.get_config_setting(example, 'core.bare')
    RJGit::Repo.any_instance.unstub(:config)
    assert_equal 'false', @test_git.get_config_setting(example, 'core.bare')
    assert_equal nil, @test_git.get_config_setting(example, 'core.bare.nothing')
    assert_equal nil, @test_git.get_config_setting(example, 'core')
    assert_equal nil, @test_git.get_config_setting(File.join('/','tmp'), 'core.bare')
  end
  
end