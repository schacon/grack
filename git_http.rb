class GitHttp
  class App 

    SERVICES = [
      ["GET",  "/HEAD$", 'get_text_file'],
      ["GET",  "/info/refs$", 'get_info_refs'],
      ["GET",  "/objects/info/alternates$", 'get_text_file'],
      ["GET",  "/objects/info/http-alternates$", 'get_text_file'],
      ["GET",  "/objects/info/packs$", 'get_info_packs'],
      ["GET",  "/objects/info/[^/]*$", 'get_text_file'],
      ["GET",  "/objects/[0-9a-f]{2}/[0-9a-f]{38}$", 'get_loose_object'],
      ["GET",  "/objects/pack/pack-[0-9a-f]{40}\\.pack$", 'get_pack_file'],
      ["GET",  "/objects/pack/pack-[0-9a-f]{40}\\.idx$", 'get_idx_file'],
      ["POST", "/git-upload-pack$", 'service_rpc'],
      ["POST", "/git-receive-pack$", 'service_rpc']
    ]

    def initialize(config)
      @config = config
    end

    def call(env)
      @req = Rack::Request.new(env)

      cmd = nil
      SERVICES.each do |method, match, handler|
        if Regexp.new(match).match(@req.path)
          return render_method_not_allowed if method != @req.request_method
          cmd = handler
        end
      end

      return render_not_found if !cmd

      # TODO: get git directory
      if dir = get_git_dir
        Dir.chdir(dir) do
          self.method(cmd).call()
        end
      else
        return render_not_found
      end
    end

    def get_git_dir
      "/opt/schacon/grit/.git"
    end

    def service_rpc
      input = @req.body.read

      pp @req.content_type # application/x-git-%s-request
      pp @req.path
      pp input
      
      @res = Rack::Response.new
      @res["Content-Type"] = "application/x-git-%s-result"
      @res.status = 500
      @res.finish do
        # test
      end
    end

    def get_text_file
    end

    def get_service_type
      service_type = @req.params['service']
      if service_type[0, 4] != 'git-'
        return false
      end
      # TODO: check that the service is allowed
      service_type.gsub('git-', '')
    end

    def get_info_refs
      service_name = get_service_type
      return render_method_not_allowed if !service_name

      refs = `git #{service_name} --stateless-rpc --advertise-refs .`

      @res = Rack::Response.new
      @res.status = 200
      @res["Content-Type"] = "application/x-git-%s-advertisement" % service_name
      hdr_nocache
      @res.write(pkt_write("# service=git-#{service_name}\n"))
      @res.write(pkt_flush)
      @res.write(refs)
      @res.finish
    end

    def pkt_flush
      '0000'
    end

    def pkt_write(str)
      (str.size + 4).to_s(base=16).rjust(4, '0') + str
    end

    def get_info_packs
    end

    def get_text_file
    end

    def get_loose_object
    end

    def get_pack_file
    end

    def get_idx_file
    end

    PLAIN_TYPE = {"Content-Type" => "text/plain"}

    def render_method_not_allowed
      if @env['SERVER_PROTOCOL'] == "HTTP/1.1"
        [405, PLAIN_TYPE, ["Method Not Allowed"]]
      else
        [400, PLAIN_TYPE, ["Bad Request"]]
      end
    end

    def render_not_found
      [404, PLAIN_TYPE, ["Not Found"]]
    end

    def hdr_nocache
      @res["Expires"] = "Fri, 01 Jan 1980 00:00:00 GMT"
      @res["Pragma"] = "no-cache"
      @res["Cache-Control"] = "no-cache, max-age=0, must-revalidate"
    end

    def hdr_cache_forever
      now = Time.now().to_i
      @res["Date"] = now.to_s
      @res["Expires"] = (now + 31536000).to_s;
      @res["Cache-Control"] = "public, max-age=31536000";
    end

  end
end