# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'minitest/autorun'
require 'vps_cli'
require 'fileutils'
require 'logger'

TEST_ROOT = File.expand_path(__dir__)

BACKUP_DIR = File.join(TEST_ROOT, 'backup_dir')
LOCAL_DIR = File.join(TEST_ROOT, 'local_dir')
TEST_CONFIG_FILES = File.join(TEST_ROOT, 'config_files')
TEST_DOTFILES = File.join(TEST_CONFIG_FILES, 'dotfiles')
TEST_MISC_FILES = File.join(TEST_CONFIG_FILES, 'miscfiles')
TEST_LOCAL_SSHD_CONFIG = File.join(LOCAL_DIR, 'sshd_config')

LOG_DIR = File.join(TEST_ROOT, 'logs')

## HELPER METHODS ##
def mk_dirs(*args)
  args.flatten.each { |dir| FileUtils.mkdir_p(dir) }
end

def rm_dirs(*args)
  args.flatten.each { |dir| FileUtils.rm_rf(dir) }
end

def convert_to_dotfiles(*files)
  files.flatten.map { |file| ".#{file}" }
end

def convert_to_origfiles(*files)
  files.flatten.map { |file| "#{file}.orig" }
end

# @return [Hash] Hash of base options to be used for testing
def test_options
  {
    backup_dir: BACKUP_DIR,
    local_dir: LOCAL_DIR,
    dotfiles_dir: TEST_DOTFILES,
    misc_files_dir: TEST_MISC_FILES,
    local_sshd_config: TEST_LOCAL_SSHD_CONFIG,
    verbose: true,
    testing: true,
    interactive: false
  }
end

# @param [File] Name of log file
# @return [Logger] Returns a log file
def create_logger(filename)
  FileUtils.mkdir_p(LOG_DIR) unless File.exist?(LOG_DIR)

  # Turns into test_#{file}.log
  logname = "#{File.basename(filename, '.rb')}.log"
  logfile = File.join(LOG_DIR, logname)

  # Creates a new logfile and removes the old logfile
  # file = File.open(logfile, File::WRONLY | File::APPEND | File::CREAT)
  file = File.new(logfile, 'w+')
  Logger.new(file)
end

##
# Logs the methods given into the log file
# @param [Logger] The logger with which to write to
# @param [Block] This must be given a block to run the method
# @return [Logger] Returns the logger file
def log_methods(logger)
  # provides better performance than caller[0]
  # returns the test_method
  calling_method = caller(1..1).first.split('`').last
  logger.debug { calling_method }

  out, err = capture_io do
    yield
  end

  logger.info { out }
  logger.error { err }
  logger
end

def add_files(dir, *files)
  FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
  files.flatten.each do |file|
    File.new(File.join(dir, file), 'w+')
  end
end

def add_files_to_dotfiles(*args)
  args.flatten.each do |name|
    add_files(TEST_DOTFILES, name)
  end
end

def add_dirs(dir, *dirs)
  dirs.flatten.each do |name|
    FileUtils.mkdir_p(File.join(dir, name))
  end
end

def add_dirs_to_dotfiles(*args)
  args.flatten.each do |name|
    add_dirs(TEST_DOTFILES, name)
  end
end

## END OF HELPER METHODS ##
