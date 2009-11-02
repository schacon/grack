Ruby/Rack Git Smart-HTTP Server Handler
=======================================

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

Quick Start
========================
$ gem install rack
$ export GIT_PROJECT_ROOT=/path/to/repos
$ rackup config.ru

Installation
========================
(examples for CGI/FCGI for Apache, Lighttpd, Nginx)
(using Mongrel/Thin/Unicorn handlers)
(generating and deploying a WAR file with Warbler)

