class GitController
  attr_accessor :git_path

  def initialize(path = nil)
    path = path == nil ? 'git' : path 
    @git_path = path 
  end
  
  def command_options
    {
      :stateless_rpc => "--stateless-rpc",
      :advertise_refs => "--advertise-refs"	
    }
  end  

  def command(cmd, args = [], &block)
    cmd = @git_path + " " + cmd + " " + args.join(" ")
    if block_given? then
      IO.popen(cmd, File::RDWR) do |pipe|
        yield pipe
      end
    else
      result = `#{cmd}`
    end
  end
  
  def upload_pack(repository, opts = {}, &block)
    cmd = "upload-pack"
    args = []
    opts.each {|k,v| args.push command_options[k]}
    args.push repository
    self.command(cmd, args, &block)
  end
  
  def receive_pack(repository, opts = {}, &block)
    cmd = "receive-pack"
    args = []
    opts.each {|k,v| args.push command_options[k]}
    args.push repository
    self.command(cmd, args, &block)
  end
  
  def update_server_info(repository, opts = {}, &block)
    cmd = "update-server-info"
    args = []
    opts.each {|k,v| args.push command_options[k]}
    Dir.chdir(repository) do # "git update-server-info" does not take a parameter to specify the repository, so set the working directory to the repository
      self.command(cmd, args, &block)
    end
  end

  def get_config_setting(repository_root, key)
    path = get_config_location(repository_root)
    raise "Config file could not be found for repository in #{repository_root}." if path == nil
    self.command("config", ["-f #{path}", key]).chomp
  end

  def get_config_location(repository_root)
    non_bare = File.join(repository_root,'.git') # This is where the config file will be if the repository is non-bare
    if File.exists?(non_bare) then # The repository is non-bare
      non_bare_config = File.join(non_bare, 'config')
      return non_bare_config if File.exists?(non_bare_config)
    else # We are dealing with a bare repository
      bare_config = File.join(repository_root, "config")
      return bare_config if File.exists?(bare_config)
    end
    return nil
  end

end
