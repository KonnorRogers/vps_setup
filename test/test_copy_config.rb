# frozen_string_literal: true

require 'test_helper'
require 'fileutils'
require 'stringio'

class TestCopyConfig < Minitest::Test
  def setup
    @backup_dir = File.join(File.expand_path(__dir__), 'backup_dir')
    @dest_dir = File.join(File.expand_path(__dir__), 'dest_dir')
  end

  def teardown
    FileUtils.rm_rf(@backup_dir)
    FileUtils.rm_rf(@dest_dir)
  end

  def test_creates_backup_dir_and_dest_dir
    refute(Dir.exist?(@backup_dir))
    refute(Dir.exist?(@dest_dir))

    CopyConfig.copy(backup_dir: @backup_dir, dest_dir: @dest_dir)

    assert(Dir.exist?(@backup_dir))
    assert(Dir.exist?(@dest_dir))
  end

  def test_will_not_error_if_backup_dir_and_dest_dir_exist
    Dir.mkdir(@backup_dir)
    Dir.mkdir(@dest_dir)
    assert(Dir.exist?(@backup_dir))
    assert(Dir.exist?(@dest_dir))

    CopyConfig.copy(backup_dir: @backup_dir, dest_dir: @dest_dir)
    assert(Dir.exist?(@backup_dir))
    assert(Dir.exist?(@dest_dir))
  end

  def test_backup_dir_empty_and_dest_dir_should_not_be_empty
    CopyConfig.copy(backup_dir: @backup_dir, dest_dir: @dest_dir)
    # Will not add files to the backup_dir if original dotfiles do not exist
    assert_empty(Dir.children(@backup_dir))

    refute_empty(Dir.children(@dest_dir))
    assert_includes(Dir.children(@dest_dir), '.vimrc')
  end

  def test_backup_dir_not_empty_if_orig_found
    Dir.mkdir(@dest_dir)
    backup_file = File.join(@backup_dir, '.vimrc.orig')
    dest_file = File.join(@dest_dir, '.vimrc')

    File.open(dest_file, 'w+') { |file| file.puts 'test' }
    dest_file_before_copy = File.read(dest_file)

    CopyConfig.copy(backup_dir: @backup_dir, dest_dir: @dest_dir)

    refute_empty(Dir.children(@backup_dir))
    assert_includes(Dir.children(@backup_dir), '.vimrc.orig')

    assert dest_file_before_copy == File.read(backup_file)
    refute dest_file_before_copy == File.read(dest_file)
  end

  def test_backup_file_will_not_be_overwritten
    Dir.mkdir(@dest_dir)
    Dir.mkdir(@backup_dir)
    f1 = File.join(@dest_dir, '.vimrc')
    f2 = File.join(@backup_dir, '.vimrc.orig')
    File.open(f1, 'w+') { |file| file.puts '1' }
    File.open(f2, 'w+') { |file| file.puts '2' }
    CopyConfig.copy(backup_dir: @backup_dir, dest_dir: @dest_dir)
    refute File.read(f1) == File.read(f2)
  end

  def test_config_file_will_be_copied_to_dest_dir
    config_file = File.join(CopyConfig::CONFIG_DIR, 'vimrc')
    dest_file = File.join(@dest_dir, '.vimrc')

    assert_raises(Errno::ENOENT) { File.read(config_file) == File.read(dest_file) }

    Dir.mkdir(@dest_dir)
    File.open(dest_file, 'w+') { |file| file.puts 'test' }
    refute File.read(config_file) == File.read(dest_file)

    CopyConfig.copy(backup_dir: @backup_dir, dest_dir: @dest_dir)

    assert File.read(config_file) == File.read(dest_file)
  end

  def test_non_unix_files_not_copied
    CopyConfig.copy(backup_dir: @backup_dir, dest_dir: @dest_dir)

    refute File.exist?(File.join(@dest_dir, '.minttyrc'))
    refute File.exist?(File.join(@dest_dir, '.cygwin_zshrc'))
  end
end
