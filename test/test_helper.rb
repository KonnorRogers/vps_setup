# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'copy_config'
require 'minitest/autorun'

def orig_stdout
  $stdout
end

def orig_stderr
  $stderr
end

def capture_out
  $stdout = StringIO.new
end

def capture_err
  $stderr = StringIO.new
end

def restore_out_err(stdout, stderr)
  $stdout = stdout
  $stderr = stderr
end
