# frozen_string_literal: true

require 'rake/testtask'

# BACKUP_DIR = File.join(Dir.home, 'backup_files')

CONFIG_DIR = File.join(File.expand_path(__dir__), 'config')
task default: %w[test]

desc 'Runs tests'
task :test do
  Rake::TestTask.new do |t|
    t.libs << 'lib'
    t.libs << 'test'
    t.test_files = FileList['test/test*.rb']
  end
end

task :example do
  # puts Process.uid
  # puts Dir.home
end
