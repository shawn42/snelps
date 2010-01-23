require 'config/environment'
require 'rake/rdoctask'
require 'lib/platform'

task :default => :run

RDOC_INCLUDES = %w(
	TODO
	MANUAL.txt
	src/*.rb
	src/gui/*.rb
	src/components/*.rb
	maps/*.yml
	maps/*.rb
	data/gameplay/*.yml
	lib/*.rb
	config/*.rb
	config/*.yml
)

RDOC_OPTIONS = ['-a', '-S', '-t Snelps Documentation']

Rake::RDocTask.new do |t|
  t.main = "src/app.rb"
	t.rdoc_files.include(RDOC_INCLUDES)
	t.options += RDOC_OPTIONS
end

desc "Run Snelps"
task :run do |t|
  if Platform.mac?
    sh "rsdl src/app.rb"
  else
    sh "ruby src/app.rb"
  end
end

desc "Run Snelps Editor"
task :edit do |t|
  if Platform.mac?
    sh "rsdl src/editor/editor.rb"
  else
    sh "ruby src/editor/editor.rb"
  end
end

desc "profile Snelps"
task :profile do |t|
  if Platform.mac?
    sh "rsdl -r profile src/app.rb"
  else
    sh "ruby -r profile src/app.rb"
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
  %w(Config            config/), 
  %w(Maps              maps/), 
  %w(Unit\ tests       specs/),
  %w(Libraries         lib/),
].collect { |name, dir| [ name, "#{APP_ROOT}/#{dir}" ] }.select { |name, dir| File.directory?(dir) }

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  require 'code_statistics'
  CodeStatistics.new(*STATS_DIRECTORIES).to_s
end

namespace :dist do
  desc "package Snelps for os x"
  task :mac do |t|
    if Platform.mac?
      # create directory structure for .app
      mac_dist_dir = File.join(APP_ROOT,"dist","mac")
      FileUtils.remove_dir mac_dist_dir, true

      dotapp_dir = File.join(APP_ROOT,"dist","mac","Snelps.app","Contents")

      FileUtils.mkdir_p(File.join(dotapp_dir,"Resources"))
      FileUtils.mkdir_p(File.join(dotapp_dir,"MacOS"))
      FileUtils.mkdir_p(File.join(dotapp_dir,"Frameworks"))

      # copy code into place
      # can I do this with svn export?
      code_dir = File.join(dotapp_dir,"Resources")
      FileUtils.cp_r(File.join(APP_ROOT,"bin"), code_dir)
      FileUtils.cp_r(File.join(APP_ROOT,"config"), code_dir)
      FileUtils.cp_r(File.join(APP_ROOT,"data"), code_dir)
      FileUtils.cp_r(File.join(APP_ROOT,"doc"), code_dir)
      FileUtils.cp_r(File.join(APP_ROOT,"glob2_data"), code_dir)
      FileUtils.cp_r(File.join(APP_ROOT,"lib"), code_dir)
      FileUtils.cp_r(File.join(APP_ROOT,"maps"), code_dir)
      FileUtils.cp_r(File.join(APP_ROOT,"scripts"), code_dir)
      FileUtils.cp_r(File.join(APP_ROOT,"src"), code_dir)
#      FileUtils.cp_r(File.join(APP_ROOT,"bin"), code_dir)

      FileUtils.cp(File.join(APP_ROOT,"LICENSE.txt"), code_dir)
      FileUtils.cp(File.join(APP_ROOT,"README.txt"), code_dir)
      FileUtils.cp(File.join(APP_ROOT,"MANUAL.txt"), code_dir)

      FileUtils.cp(File.join(APP_ROOT,"bin","MacOS","Info.plist"), dotapp_dir)
      FileUtils.cp(File.join(APP_ROOT,"bin","MacOS","snelps"), File.join(dotapp_dir,"MacOS"))

      FileUtils.cp(File.join(APP_ROOT,"bin","MacOS","script"), code_dir)
      FileUtils.cp(File.join(APP_ROOT,"bin","MacOS",".script"), code_dir)
      FileUtils.cp(File.join(APP_ROOT,"bin","MacOS","rsdl"), code_dir)
      FileUtils.cp(File.join(APP_ROOT,"bin","MacOS","AppSettings.plist"), code_dir)
      FileUtils.cp_r(File.join(APP_ROOT,"bin","MacOS","en.lproj"), code_dir)

      # copy frameworks into place
      # TODO how should I manage these?
      FRAMEWORKS_DIR = File.join(APP_ROOT,"bin","MacOS","Frameworks")
      FileUtils.cp_r(FRAMEWORKS_DIR, dotapp_dir)

      # TODO make this use svn export
      sh "rm -rf `find #{dotapp_dir} -type d -name '.svn'`"

    else
      puts "You are not on a mac"
    end
  end
end
