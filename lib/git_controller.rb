class GitController
  attr_accessor :git_path

  def initialize(path = nil)
    path = path == nil ? 'git' : path 
    @git_path = path 
  end

  def command(cmd, args = [], &block)
    cmd = @git_path + " " + cmd + " " + args.join(" ")
    if block != nil then
      IO.popen(cmd, File::RDWR) do |pipe|
        yield pipe
      end
    else
      result = `#{cmd}`
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
