require "rjgit"

module Grack

  class RJGitAdapter

    def repo(repository_path)
      RJGit::Repo.new(repository_path)
    end
  
    def service_command(cmd, repository_path, opts = {}, &block)
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
      begin
        loop_settings = repository.config
      rescue
        return nil
      end
      domains.each do |domain|
        begin
          loop_settings = loop_settings[domain]
        rescue
          return nil
        end
      end
      return loop_settings.is_a?(Hash) ? loop_settings : loop_settings.to_s
    end
  
  end

end
