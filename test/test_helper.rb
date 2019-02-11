# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'minitest/autorun'
require 'vps_cli'
require 'fileutils'
require 'logger'

TEST_ROOT = File.expand_path(__dir__)

BACKUP_DIR = File.join(TEST_ROOT, 'backup_dir')
DEST_DIR = File.join(TEST_ROOT, 'dest_dir')
TEST_DOTFILES = File.join(TEST_ROOT, 'dotfiles')
LOG_DIR = File.join(TEST_ROOT, 'logs')

## HELPER METHODS ##
def mk_dirs(*args)
  args.each { |dir| FileUtils.mkdir_p(dir) }
end

def rm_dirs(*args)
  args.each { |dir| FileUtils.rm_rf(dir) }
end

# @return [Logger] Returns a log file
def create_logger(filename)
  FileUtils.mkdir_p(LOG_DIR) unless File.exist?(LOG_DIR)

  # Turns into test_#{file}.log
  logname = "#{File.basename(filename, '.rb')}.log"
  logfile = File.join(LOG_DIR, logname)

  # Creates a new logfile and removes the old logfile
  file = File.open(logfile, File::WRONLY | File::APPEND | File::CREAT)
  Logger.new(file)
end

def log_methods(logger)
  out, err = capture_io do
    yield
  end

  logger.error { err }
  logger.info { out }
end

def add_file(dir, name)
  File.new(File.join(dir, name), 'w+')
end

def add_files_to_dotfiles(*args)
  args.each do |name|
    add_file(TEST_DOTFILES, name)
  end
end

def add_dir(dir, name)
  Dir.new(File.join(dir, name))
end

def add_dir_to_dotfiles(*args)
  args.each do |name|
    add_dir(TEST_DOTFILES, name)
  end
end

## END OF HELPER METHODS ##
