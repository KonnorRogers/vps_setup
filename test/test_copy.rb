# frozen_string_literal: true

require 'test_helper'

LOGGER = create_logger(__FILE__)
TEST_FILES = %w[vimrc pryrc zshrc].freeze
TEST_DIRS = %w[config dir2].freeze
BASE_DIRS = [BACKUP_DIR, DEST_DIR, TEST_DOTFILES, TEST_MISC_FILES].freeze
# The goal of testing all of this is to not touch the base config_files
# And to keep the test suite entirely independent
class TestCopy < Minitest::Test
  def setup
    rm_dirs(BASE_DIRS)
    mk_dirs(BASE_DIRS)

    # Creates a base from which to copy
    add_files_to_dotfiles(TEST_FILES)
    add_dirs_to_dotfiles(TEST_DIRS)
  end

  def teardown
    rm_dirs(BASE_DIRS)
  end

  def test_copy_dotfiles_does_not_make_a_backup_and_copies_files
    log_methods(LOGGER) do
      VpsCli::Copy.dotfiles(test_options)
    end

    # No backup should exist
    assert Dir.children(BACKUP_DIR).empty?

    # Test that dirs and files were copied
    dotfiles = convert_to_dotfiles(TEST_FILES)
    dotfiles.each { |file| assert_includes Dir.children(DEST_DIR), file }

    dotdirs = convert_to_dotfiles(TEST_DIRS)
    dotdirs.each { |dir| assert_includes Dir.children(DEST_DIR), dir }
  end

  def test_copy_dotfiles_copies_directories_properly
    test_config_dir = File.join(TEST_DOTFILES, TEST_DIRS[0])
    add_files(test_config_dir, TEST_FILES)

    TEST_FILES.each do |file|
      assert_includes Dir.children(test_config_dir), file
    end

    log_methods(LOGGER) { VpsCli::Copy.dotfiles(test_options) }

    # No backups should be created
    assert Dir.children(BACKUP_DIR).empty?

    dest_config_dir = File.join(DEST_DIR, ".#{TEST_DIRS[0]}")

    TEST_DIRS.each do |dir|
      # Config turns to .config etc
      dot_dir = ".#{dir}"
      assert_includes Dir.children(DEST_DIR), dot_dir

      next unless dir == TEST_DIRS[0]

      # checks for files embedded in the dir
      TEST_FILES.each do |file|
        assert_includes Dir.children(dest_config_dir), file
      end
    end
  end

  def test_creates_backups_of_dotfiles
    dotfiles = convert_to_dotfiles(TEST_FILES)
    add_files(DEST_DIR, dotfiles)

    refute_empty Dir.children(DEST_DIR)

    log_methods(LOGGER) { VpsCli::Copy.dotfiles(test_options) }

    refute_empty Dir.children(BACKUP_DIR)

    origfiles = convert_to_origfiles(TEST_FILES)
    origfiles.each do |file|
      assert_includes Dir.children(BACKUP_DIR), file
    end
  end

  def test_copy_sshd_config_works_in_testing_environment
    add_files(DEST_DIR, 'sshd_config')
    add_files(TEST_MISC_FILES, 'sshd_config')

    assert_empty Dir.children(test_options[:backup_dir])

    log_methods(LOGGER) { VpsCli::Copy.sshd_config(test_options) }

    refute_empty Dir.children(test_options[:backup_dir])
    assert_includes Dir.children(test_options[:backup_dir]), 'sshd_config.orig'
    assert_includes Dir.children(test_options[:local_dir]), 'sshd_config'
  end

  def test_copy_gnome_settings_properly_errors
    errors = nil
    log_methods(LOGGER) do
      errors = VpsCli::Copy.gnome_settings(test_options)
      refute_empty VpsCli.errors
      refute_empty errors
    end
  end

  def test_raise_error_on_root_run
    # Stubbing process and dir mimic running as root
    Process.stub :uid, 0 do
      Dir.stub :home, '/root' do
        assert_raises(RuntimeError) { VpsCli::Copy.all }
      end
    end
  end

  def test_copy_works_properly
    backupfiles = convert_to_origfiles(TEST_FILES, TEST_DIRS)
    dotfiles = convert_to_dotfiles(TEST_FILES, TEST_DIRS)

    add_files(TEST_DOTFILES, TEST_FILES)
    add_files(TEST_MISC_FILES, 'sshd_config')

    log_methods(LOGGER) { VpsCli::Copy.all(test_options) }

    assert_empty Dir.children(BACKUP_DIR)
    dotfiles.each { |file| assert_includes Dir.children(DEST_DIR), file }

    # reset
    rm_dirs(BASE_DIRS)
    mk_dirs(BASE_DIRS)

    add_files(TEST_DOTFILES, TEST_FILES)
    add_files(TEST_MISC_FILES, 'sshd_config')
    add_files(DEST_DIR, 'sshd_config')
    add_dirs(TEST_DOTFILES, TEST_DIRS)

    log_methods(LOGGER) { VpsCli::Copy.all(test_options) }

    # Will create a backup due to sshd_config having to exist
    assert_includes Dir.children(BACKUP_DIR), 'sshd_config.orig'
    assert_equal Dir.children(BACKUP_DIR).size, 1


    rm_dirs(BASE_DIRS)
    mk_dirs(BASE_DIRS)

    add_files(TEST_DOTFILES, TEST_FILES)
    add_dirs(TEST_DOTFILES, TEST_DIRS)
    add_files(DEST_DIR, convert_to_dotfiles(TEST_FILES))
    add_dirs(DEST_DIR, convert_to_dotfiles(TEST_DIRS))
    add_files(TEST_MISC_FILES, 'sshd_config')
    add_files(DEST_DIR, 'sshd_config')

    log_methods(LOGGER) { VpsCli::Copy.all(test_options) }

    refute_empty Dir.children(BACKUP_DIR)
    backupfiles.each { |file| assert_includes Dir.children(BACKUP_DIR), file }
  end
end
