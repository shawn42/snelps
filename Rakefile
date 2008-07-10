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

desc "Run an Snelps"
task :run do |t|
  if Platform.mac?
    sh "rsdl src/app.rb"
  else
    sh "ruby src/app.rb"
  end
end

begin
  require 'spec/rake/spectask'

  desc "Run all specs (tests)"
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList['specs/*_spec.rb']
    t.spec_opts = ["--format", "specdoc"]
  end

  rule(/spec:.+/) do |t|
    name = t.name.gsub("spec:","")

    path = File.join( File.dirname(__FILE__),'specs','%s_spec.rb'%name )

    if File.exist? path
      Spec::Rake::SpecTask.new(name) do |t|
      t.spec_files = [path]
    end

    puts "\nRunning spec/%s_spec.rb"%[name]
      Rake::Task[name].invoke
    else
      puts "File does not exist: %s"%path
    end
  end

rescue LoadError
  task :spec do 
    puts "ERROR: RSpec is not installed?"
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
