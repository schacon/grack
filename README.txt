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

With Warbler (http://caldersphere.rubyforge.org/warbler/classes/Warbler.html),
and JRuby, we can also generate a WAR file that can be deployed in any Java
web application server (Tomcat, Glassfish, Websphere, JBoss, etc).

Since the git-http-backend is really just a simple wrapper for the upload-pack
and receive-pack processes with the '--stateless-rpc' option, it does not 
actually re-implement very much.

Dependencies
========================
Ruby - http://www.ruby-lang.org
Rack - http://rack.rubyforge.org
A Rack-compatible web server
Git >= 1.7
Mocha (only for running the tests)

Quick Start
========================
$ gem install rack
$ (edit config.ru to set git project path)
$ rackup --host 127.0.0.1 -p 8080 config.ru
$ git clone http://127.0.0.1:8080/schacon/grit.git 

Contributing
========================
If you would like to contribute to the Grack project, I prefer to get
pull-requests via GitHub.  You should include tests for whatever functionality
you add.  Just fork this project, push your changes to your fork and click
the 'pull request' button.  To run the tests, you first need to install the 
'mocha' mocking library and initialize the submodule.

$ sudo gem install mocha
$ git submodule init
$ git submodule update

Then you should be able to run the tests with a 'rake' command.  You can also
run coverage tests with 'rake rcov' if you have rcov installed.

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
