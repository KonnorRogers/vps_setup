# frozen_string_literal: true

require 'test_helper'

# The goal of testing all of this is to not touch the base config_files
# And to keep the test suite entirely independent
class TestCopy < Minitest::Test
  def setup
    # These are all created prior to running the test
    # It is important to have some testable files to copy
    @logger = create_logger(__FILE__)
    @test_files = %w[vimrc pryrc zshrc].freeze
    @test_dirs = %w[config dir2].freeze
    @base_dirs = [BACKUP_DIR, LOCAL_DIR, TEST_DOTFILES, TEST_MISC_FILES].freeze

    rm_dirs(@base_dirs)
    mk_dirs(@base_dirs)

    # Creates a base from which to copy
    add_files_to_dotfiles(@test_files)
    add_dirs_to_dotfiles(@test_dirs)
  end

  def teardown
    rm_dirs(@base_dirs)
  end

  def test_copy_dotfiles_does_not_make_a_backup_and_copies_files
    log_methods(@logger) do
      VpsCli::Copy.dotfiles(test_options)
    end

    # No backup should exist
    assert_equal Dir.children(BACKUP_DIR).size, 2

    # Test that dirs and files were copied
    dotfiles = convert_to_dotfiles(@test_files)
    dotfiles.each { |file| assert_includes Dir.children(LOCAL_DIR), file }

    dotdirs = convert_to_dotfiles(@test_dirs)
    dotdirs.each { |dir| assert_includes Dir.children(LOCAL_DIR), dir }
  end

  def test_copy_dotfiles_copies_directories_properly
    test_config_dir = File.join(TEST_DOTFILES, @test_dirs[0])
    add_files(test_config_dir, @test_files)

    @test_files.each do |file|
      assert_includes Dir.children(test_config_dir), file
    end

    log_methods(@logger) { VpsCli::Copy.dotfiles(test_options) }

    # directory backups only
    assert_equal Dir.children(BACKUP_DIR).size, 2

    dest_config_dir = File.join(LOCAL_DIR, ".#{@test_dirs[0]}")

    @test_dirs.each do |dir|
      # Config turns to .config etc
      dot_dir = ".#{dir}"
      assert_includes Dir.children(LOCAL_DIR), dot_dir

      next unless dir == @test_dirs[0]

      # checks for files embedded in the dir
      @test_files.each do |file|
        assert_includes Dir.children(dest_config_dir), file
      end
    end
  end

  def test_creates_backups_of_dotfiles
    dotfiles = convert_to_dotfiles(@test_files)
    add_files(LOCAL_DIR, dotfiles)

    refute_empty Dir.children(LOCAL_DIR)

    log_methods(@logger) { VpsCli::Copy.dotfiles(test_options) }
    refute_empty Dir.children(BACKUP_DIR)

    origfiles = convert_to_origfiles(@test_files)
    origfiles.each do |file|
      assert_includes Dir.children(BACKUP_DIR), file
    end
  end

  def test_copy_sshd_config_works_in_testing_environment
    add_files(LOCAL_DIR, 'sshd_config')
    add_files(TEST_MISC_FILES, 'sshd_config')

    assert_empty Dir.children(test_options[:backup_dir])

    log_methods(@logger) { VpsCli::Copy.sshd_config(test_options) }

    refute_empty Dir.children(test_options[:backup_dir])
    assert_includes Dir.children(test_options[:backup_dir]), 'sshd_config.orig'
    assert_includes Dir.children(test_options[:local_dir]), 'sshd_config'
  end

  def test_copy_gnome_settings_properly_errors
    errors = nil
    log_methods(@logger) do
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
    backupfiles = convert_to_origfiles(@test_files, @test_dirs)
    dotfiles = convert_to_dotfiles(@test_files, @test_dirs)

    add_files(TEST_DOTFILES, @test_files)
    add_files(TEST_MISC_FILES, 'sshd_config')

    log_methods(@logger) { VpsCli::Copy.all(test_options) }

    assert_equal Dir.children(BACKUP_DIR).size, 2
    dotfiles.each { |file| assert_includes Dir.children(LOCAL_DIR), file }

    # reset
    rm_dirs(@base_dirs)
    mk_dirs(@base_dirs)

    add_files(TEST_DOTFILES, @test_files)
    add_files(TEST_MISC_FILES, 'sshd_config')
    add_files(LOCAL_DIR, 'sshd_config')
    add_dirs(TEST_DOTFILES, @test_dirs)

    log_methods(@logger) { VpsCli::Copy.all(test_options) }

    # Will create a backup due to sshd_config having to exist
    assert_includes Dir.children(BACKUP_DIR), 'sshd_config.orig'
    assert_equal Dir.children(BACKUP_DIR).size, 3

    rm_dirs(@base_dirs)
    mk_dirs(@base_dirs)

    add_files(TEST_DOTFILES, @test_files)
    add_dirs(TEST_DOTFILES, @test_dirs)
    add_files(LOCAL_DIR, convert_to_dotfiles(@test_files))
    add_dirs(LOCAL_DIR, convert_to_dotfiles(@test_dirs))
    add_files(TEST_MISC_FILES, 'sshd_config')
    add_files(LOCAL_DIR, 'sshd_config')

    log_methods(@logger) { VpsCli::Copy.all(test_options) }

    refute_empty Dir.children(BACKUP_DIR)
    backupfiles.each { |file| assert_includes Dir.children(BACKUP_DIR), file }
  end
end
