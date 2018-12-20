# frozen_string_literal: true

require 'rake/testtask'

BACKUP_DIR = File.join(Dir.home, 'backup')
CONFIG_DIR = File.join(__dir__, 'config')

task default: %w[test]

desc 'Runs tests'
task :test do
  Rake::TestTask.new do |t|
    t.libs << 'lib'
    t.libs << 'test'
    t.test_files = FileList['test/test*.rb']
  end
end

desc 'copies files from config dir to home dir, will place existing dotfiles into a backupdir'
# Allows the setting of a backup_dir for your dotfiles
task :copy_config, [:backup_dir] do |_t, args|
  args.with_defaults(backup_dir: BACKUP_DIR)
end
