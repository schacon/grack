require 'zlib'
require 'rack/request'
require 'rack/response'
require 'pp'

class GitHttp
  class App 

    SERVICES = [
      ["POST", 'service_rpc',      "(.*?)/git-upload-pack$",  'upload-pack'],
      ["POST", 'service_rpc',      "(.*?)/git-receive-pack$", 'receive-pack']

      ["GET",  'get_info_refs',    "(.*?)/info/refs$"],
      ["GET",  'get_text_file',    "(.*?)/HEAD$"],
      ["GET",  'get_text_file',    "(.*?)/objects/info/alternates$"],
      ["GET",  'get_text_file',    "(.*?)/objects/info/http-alternates$"],
      ["GET",  'get_info_packs',   "(.*?)/objects/info/packs$"],
      ["GET",  'get_text_file',    "(.*?)/objects/info/[^/]*$"],
      ["GET",  'get_loose_object', "(.*?)/objects/[0-9a-f]{2}/[0-9a-f]{38}$"],
      ["GET",  'get_pack_file',    "(.*?)/objects/pack/pack-[0-9a-f]{40}\\.pack$"],
      ["GET",  'get_idx_file',     "(.*?)/objects/pack/pack-[0-9a-f]{40}\\.idx$"],      
    ]

    def initialize(config)
      @config = config
    end

    def call(env)
      @env = env
      @req = Rack::Request.new(env)

      cmd = nil
      path = nil
      SERVICES.each do |method, handler, match, rpc|
        if m = Regexp.new(match).match(@req.path)
          return render_method_not_allowed if method != @req.request_method
          cmd = handler
          @rpc = rpc
          path = m[1]
        end
      end

      return render_not_found if !cmd

      # TODO: get git directory
      if @dir = get_git_dir(path)
        Dir.chdir(@dir) do
          self.method(cmd).call()
        end
      else
        return render_not_found
      end
    end

    # ------------------------
    # actual command handling functions
    # ------------------------

    def service_rpc

      # TODO: check receive-pack access
      
      if @env["HTTP_CONTENT_ENCODING"] =~ /gzip/
        input = Zlib::GzipReader.new(@req.body).read
      else
        input = @req.body.read
      end
      
      # TODO: check @req.content_type # application/x-git-%s-request
      
      @res = Rack::Response.new
      @res.status = 200
      @res["Content-Type"] = "application/x-git-%s-result" % @rpc
      @res.finish do
        IO.popen("git --git-dir=#{@dir} #{@rpc} --stateless-rpc #{@dir}", File::RDWR) do |pipe|
          pipe.write(input)
          while !pipe.eof?
            block = pipe.read(4016)
            @res.write block
          end
        end
      end
    end

    def get_info_refs
      service_name = get_service_type
      if service_name
        refs = `git #{service_name} --stateless-rpc --advertise-refs .`

        @res = Rack::Response.new
        @res.status = 200
        @res["Content-Type"] = "application/x-git-%s-advertisement" % service_name
        hdr_nocache
        @res.write(pkt_write("# service=git-#{service_name}\n"))
        @res.write(pkt_flush)
        @res.write(refs)
        @res.finish
      else
        # TODO: old info_refs functionality
      end
    end

    def get_info_packs
      # "text/plain; charset=utf-8"
    end

    def get_loose_object
      #hdr_cache_forever();
      #send_file("application/x-git-loose-object", name);
    end

    def get_pack_file
      #hdr_cache_forever();
      #send_file("application/x-git-packed-objects", name);
    end

    def get_idx_file
      #hdr_cache_forever();
      #send_file("application/x-git-packed-objects-toc", name);
    end

    def get_text_file
      #hdr_nocache();
      #send_file("text/plain", name);
    end


    # ------------------------
    # logic helping functions
    # ------------------------

    def get_git_dir(path)
      root = @config[:project_root] || `pwd`
      path = File.join(root, path)
      if File.exists?(path) # TODO: check is a valid git directory
        return path
      end
      false
    end

    def get_service_type
      service_type = @req.params['service']
      if service_type[0, 4] != 'git-'
        return false
      end
      # TODO: check that the service is allowed
      service_type.gsub('git-', '')
    end


    # ------------------------
    # HTTP error response handling functions
    # ------------------------

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


    # ------------------------
    # packet-line handling functions
    # ------------------------

    def pkt_flush
      '0000'
    end

    def pkt_write(str)
      (str.size + 4).to_s(base=16).rjust(4, '0') + str
    end


    # ------------------------
    # header writing functions
    # ------------------------

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