task :default => :test
 
desc "Run the tests."
task :test do
  Dir.glob("tests/*_test.rb").each do |file|
  	require file
  end
end

desc "Run test coverage."
task :rcov do
  system "rcov tests/test.rb -i lib/git_http.rb -x rack -x Library -x tests"
  system "open coverage/index.html"
end

namespace :grack do
  desc "Start Grack"
  task :start do
    system "rackup config.ru -p 8080"
  end
end
 
desc "Start everything."
multitask :start => [ 'grack:start' ]
