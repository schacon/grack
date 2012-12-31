require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require './lib/git_controller'


class GitControllerTest < Test::Unit::TestCase

  attr_accessor :test_git
  
  GIT_STATUS_RESPONSE = "nothing to commit (working directory clean)"
  
  def git
    'git' # Path to git on test system
  end
  
  def example
    File.expand_path(File.join(File.dirname(__FILE__),'example'))
  end

  def setup
    @test_git = GitController.new(git)
  end
  
  def test_init
    assert_equal git, @test_git.git_path
    @test_git = GitController.new('/tmp/git')
    assert_equal '/tmp/git', @test_git.git_path
  end
  
  def test_command
    assert_equal GIT_STATUS_RESPONSE, @test_git.command("status", [example]).split("\n").last
    
    @test_git.command("upload-pack", [example]) do |pipe|
      assert_equal false, pipe.eof?
      pipe.write "0000"
      pipe.read
      assert_raise(Errno::EPIPE) { pipe.write "test" }
    end
    
  end
  
  def test_get_config_location
    dot_git = File.join(example, '.git')
    non_bare_location = File.join(dot_git,'config')
    bare_location = File.join(example, 'config')
    
    assert_equal non_bare_location, @test_git.get_config_location(example)
    
    File.stubs(:exists?).with(dot_git).returns(false)
    File.stubs(:exists?).with(bare_location).returns(true)
    assert_equal bare_location, @test_git.get_config_location(example)
    
    File.stubs(:exists?).with(dot_git).returns(false)
    File.stubs(:exists?).with(bare_location).returns(false)
    assert_equal nil, @test_git.get_config_location(example)
  end
  
  def test_get_config_setting
    assert_equal 'false', @test_git.get_config_setting(example, 'core.bare')
    
    @test_git.stubs(:get_config_location).with(example).returns(nil)
    assert_raise(RuntimeError) { @test_git.get_config_setting(example, 'core.bare') }
  end
  
end