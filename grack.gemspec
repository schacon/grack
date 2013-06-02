Gem::Specification.new do |s|
  s.name = 'grack'
  s.version = '0.1.0'
  s.date = '2013-06-02'
  s.summary = "This project aims to replace the builtin git-http-backend CGI handler
distributed with C Git with a Rack application."
  s.description = "This project aims to replace the builtin git-http-backend CGI handler
distributed with C Git with a Rack application. By default, Grack uses calls to git on the system to implement Smart-Http. Since the git-http-backend is really just a simple wrapper for the upload-pack
and receive-pack processes with the '--stateless-rpc' option, this does not actually re-implement very much. However, it is possible to use a different backend by specifying a different Adapter."
  s.authors = ['Scott Chacon', 'Dawa Ometto']
  s.email = 'schacon@gmail.com'
  s.files = ["lib/grack.rb", "lib/git_adapter.rb", "README.md", "install.txt", "Gemfile"]
  s.homepage = "http://github.com/schacon/grack"
  s.license = 'MIT'

  s.add_dependency('rack')
end
