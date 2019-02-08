# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'minitest/autorun'
require 'vps_cli'
require 'fileutils'

TEST_ROOT = File.expand_path(__dir__)
BACKUP_DIR = File.join(TEST_ROOT, 'backup_dir')
DEST_DIR = File.join(TEST_ROOT, 'dest_dir')

## HELPER METHODS ##
def mk_dirs(*args)
  args.each { |dir| FileUtils.mkdir_p(dir) }
end

def rm_dirs(*args)
  args.each { |dir| FileUtils.rm_rf(dir) }
end

## END OF HELPER METHODS ##
