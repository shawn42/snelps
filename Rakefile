require 'config/environment'
require 'rake/rdoctask'
require 'lib/platform'

task :default => :run

RDOC_INCLUDES = %w(
	TODO
	src/*.rb
	lib/*.rb
	config/*.rb
)

RDOC_OPTIONS = ['-a', '-S', '-t Snelps Documentation']

Rake::RDocTask.new do |t|
  t.main = "src/app.rb"
	t.rdoc_files.include(RDOC_INCLUDES)
	t.options += RDOC_OPTIONS
end

desc "Update the data" 
task :data do |t|
  sh "./scripts/syncdata"
end

desc "Run an example map"
task :run do |t|
  if Platform.mac?
    sh "rsdl src/app.rb obs"
  else
    sh "ruby src/app.rb obs"
  end
end

desc "Run the editor"
task :editor do |t|
  if Platform.mac?
    sh "rsdl src/ed_app.rb tmp 100"
  else
    sh "ruby src/ed_app.rb tmp 100"
  end
end

desc "Run all the unit tests"
task :test do |t|
  puts "TODO: make this actually run all the tests..."
  if Platform.mac?
    sh "rsdl test/unit/*_test.rb"
  else
    sh "ruby test/unit/*_test.rb"
  end
end

STATS_DIRECTORIES = [
  %w(Source            src/), 
  %w(Unit\ tests        test/),
  %w(Libraries          lib/),
].collect { |name, dir| [ name, "#{APP_ROOT}/#{dir}" ] }.select { |name, dir| File.directory?(dir) }

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  require 'code_statistics'
  CodeStatistics.new(*STATS_DIRECTORIES).to_s
end
