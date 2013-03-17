require "~/projects/repotag/gems/rjgit/lib/rjgit.rb"

class RJGitController

  def repo(repository_path)
    RJGit::Repo.new(repository_path)
  end
  
  def service_command(cmd, repository_path, opts = {}, &block)
    r = repo(repository_path)
    pack = case cmd
      when :upload_pack
        RJGit::RJGitUploadPack.new(repo repository_path)
      when :receive_pack
        RJGit::RJGitReceivePack.new(repo repository_path)
      else
        nil
      end
    return nil unless pack
    if opts[:advertise_refs] then
      return pack.advertise_refs
    else
      msg = opts.has_key?(:msg) ? opts[:msg] : ""
      result, err = pack.process(msg)
      if block_given? then
        yield result
      else
        return result.read
      end
    end    
  end
  
  def upload_pack(repository_path, opts = {}, &block)
    self.service_command(:upload_pack, repository_path, opts, &block)
  end
  
  def receive_pack(repository_path, opts = {}, &block)
    self.service_command(:receive_pack, repository_path, opts, &block)
  end
  
  def update_server_info(repository_path, opts = {}, &block)
    repo(repository_path).update_server_info
  end

  def get_config_setting(repository_path, key)
    repository = repo(repository_path)
    domains = key.split(".")
    return nil if domains.length < 2
    begin
      loop_settings = repository.config
    rescue
      return nil
    end
    domains.each do |domain|
      return nil unless (loop_settings.is_a?(RJGit::Config::Group) || loop_settings.is_a?(RJGit::Config))
      loop_settings = loop_settings[domain]
      break if loop_settings == nil
    end
    if loop_settings == nil then
      return nil
    else
      return loop_settings.value
    end
  end
  
end
