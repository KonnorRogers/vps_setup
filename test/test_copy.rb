# frozen_string_literal: true

require 'test_helper'

class TestCopy < Minitest::Test
  include VpsCli

  def setup
    rm_dirs(BACKUP_DIR, DEST_DIR)
    mkdirs(BACKUP_DIR, DEST_DIR)
  end

  def teardown
    rm_dirs(BACKUP_DIR, DEST_DIR)
  end
end
