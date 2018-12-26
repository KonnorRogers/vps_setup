# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'minitest/autorun'
require 'vps_setup'

ROOT = File.expand_path(__dir__)

BACKUP_DIR = File.join(ROOT, 'backup_dir')
DEST_DIR = File.join(ROOT, 'dest_dir')

LOGS_DIR = File.join(ROOT, 'logs')
mkdir_p(LOGS_DIR) unless Dir.exist?(LOGS_DIR)

def capture_console
  orig_err = $stderr
  orig_out = $stdout
  $stdout = fake_out = StringIO.new
  $stderr = fake_err = StringIO.new
  {
    orig_err: orig_err,
    orig_out: orig_out,
    fake_out: fake_out,
    fake_err: fake_err
  }
end

def restore_out_err(console)
  $stdout = console[:orig_out]
  $stderr = console[:orig_err]
end
