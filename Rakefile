# frozen_string_literal: true

LOAD_PATH = File.dirname(File.expand_path(__FILE__))

CONFIG_DIR = File.expand_path("config")

task :example do
  # p LOAD_PATH
  # sh 'echo', 'hi' # *cmd, &block
end

desc 'copies files from config dir to home dir'
task :copy_config do
  FileList.new(Dir.children('config')).each do |file|
    next if file == 'sshd_config'
    puts file
  end
end
