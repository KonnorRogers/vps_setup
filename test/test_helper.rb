# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'copy_config'
require 'minitest/autorun'

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
