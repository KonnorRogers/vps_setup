# frozen_string_literal: true

require 'fileutils'

LOAD_PATH = File.dirname(File.expand_path(__FILE__))

task :example do
  # p LOAD_PATH
  # sh 'echo', 'hi' # *cmd, &block
end

desc 'copies files from config dir to home dir'
task :copy_config do
  FileList.new(Dir.children('config')).each do |file|
    dot_file = ".#{file}"
    backup_file = "#{dot_file}.orig"
    FileUtils.cp(file, Dir.home)
  end
end
