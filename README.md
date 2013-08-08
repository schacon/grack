Grack - Ruby/Rack Git Smart-HTTP Server Handler
===============================================

This project aims to replace the builtin git-http-backend CGI handler
distributed with C Git with a Rack application.  This reason for doing this
is to allow far more webservers to be able to handle Git smart http requests.

The default git-http-backend only runs as a CGI script, and specifically is
only targeted for Apache 2.x usage (it requires PATH_INFO to be set and 
specifically formatted).  So, instead of trying to get it to work with
other CGI capable webservers (Lighttpd, etc), we can get it running on nearly
every major and minor webserver out there by making it Rack capable.  Rack 
applications can run with the following handlers:

* CGI
* FCGI
* Mongrel (and EventedMongrel and SwiftipliedMongrel)
* WEBrick
* SCGI
* LiteSpeed
* Thin

These web servers include Rack handlers in their distributions:

* Ebb
* Fuzed
* Phusion Passenger (which is mod_rack for Apache and for nginx)
* Unicorn

With [Warbler](http://caldersphere.rubyforge.org/warbler/classes/Warbler.html),
and JRuby, we can also generate a WAR file that can be deployed in any Java
web application server (Tomcat, Glassfish, Websphere, JBoss, etc).

By default, Grack uses calls to git on the system to implement Smart-Http. Since the git-http-backend is really just a simple wrapper for the upload-pack
and receive-pack processes with the '--stateless-rpc' option, this does not actually re-implement very much. However, it is possible to use a different backend by specifying a different Adapter. See below for a list.

Dependencies
========================
* Ruby - http://www.ruby-lang.org
* Rack - http://rack.rubyforge.org
* A Rack-compatible web server
* Git >= 1.7 (if using the standard GitAdapter, see below)
* Mocha (only for running the tests)

Quick Start
========================
	$ bundle install
	$ (edit config.ru to set git project path)
	$ rackup --host 127.0.0.1 -p 8080 config.ru
	$ git clone http://127.0.0.1:8080/tests/example/test_repo/

Adapters
========================

Grack makes calls to the git binary through the GitAdapter abstraction class. Grack can be made to use a different backend by specifying a different Adapter class in Grack's configuration, for example:

```ruby
Grack::App.new({
      :adapter => Grack::RJGitAdapter
    })
```

Alternative adapters available:
- [rjgit_grack](http://github.com/dometto/rjgit_grack) lets Grack use the [RJGit](http://github.com/repotag/rjgit) gem to implement smart-http in pure jruby.

See below if you are looking to create a custom Adapter.

Contributing
========================
If you would like to contribute to the Grack project, I prefer to get
pull-requests via GitHub.  You should include tests for whatever functionality
you add.  Just fork this project, push your changes to your fork and click
the 'pull request' button.

Run 'bundle install' to install development dependencies. Then you should be able to run the tests with a 'rake' command. On ruby >= 1.9, a coverage report will be generated using simplecov. On ruby 1.8, use rcov instead: uncomment the relevant line in the Gemfile and use 'rake rcov'. 

### Developing Adapters

Adapters are abstraction classes that handle the actual implementation of the smart-http protocol (advertising refs, uploading and receiving packfiles). Such abstraction classes must have the following methods:

```ruby
MyAdapter.receive_pack(repository_path, opts = {}, &block)
MyAdapter.upload_pack(repository_path, opts = {}, &block)
MyAdapter.update_server_info(repository_path, opts = {}, &block) # The equivalent of 'git update-server-info'. Optional, for falling back to dumb-http mode.
MyAdapter.get_config_setting(repository_path, key) # Always returns a string, e.g. "false" for key "core.bare".
```

Both upload_pack and receive_pack must return a ref-advertisement string if opts[:advertise_refs] is set to true; otherwise, they must yield an IO object that Grack uses to read the client's response from.

License
========================
	(The MIT License)

	Copyright (c) 2009 Scott Chacon <schacon@gmail.com>

	Permission is hereby granted, free of charge, to any person obtaining
	a copy of this software and associated documentation files (the
	'Software'), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject to
	the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
