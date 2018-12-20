require 'test_helper'
require 'fileutils'

class TestCopyConfig < Minitest::Test
  def setup
    @cc = CopyConfig.new
    @backup_dir = File.join(__dir__, 'backup_dir')
    @dest_dir = File.join(__dir__, 'dest_dir')
  end

  def teardown
    FileUtils.rm_rf(@backup_dir)
    FileUtils.rm_rf(@dest_dir)
  end

  def test_creates_backup_dir_and_dest_dir
    refute(Dir.exist?(@backup_dir))
    refute(Dir.exist?(@dest_dir))

    @cc.copy(backup_dir: @backup_dir, dest_dir: @dest_dir, test: true)

    assert(Dir.exist?(@backup_dir))
    assert(Dir.exist?(@dest_dir))
  end
end
