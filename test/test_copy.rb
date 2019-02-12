# frozen_string_literal: true

require 'test_helper'
require 'fileutils'

LOGGER = create_logger(__FILE__)
# The goal of testing all of this is to not touch the base config_files
# And to keep the test suite entirely independent
class TestCopy < Minitest::Test
  def setup
    rm_dirs(BACKUP_DIR, DEST_DIR, TEST_DOTFILES)
    mk_dirs(BACKUP_DIR, DEST_DIR, TEST_DOTFILES)
  end

  def teardown
    rm_dirs(BACKUP_DIR, DEST_DIR, TEST_DOTFILES)
  end

  def options
    {
      backup: BACKUP_DIR,
      dest_dir: DEST_DIR,
      dotfiles_dir: TEST_DOTFILES,
      verbose: true
    }
  end

  def test_copy_dotfiles_copies_files_properly
    log_methods(LOGGER) do
      add_files_to_dotfiles('vimrc', 'zshrc', 'pryrc')
      VpsCli::Copy.copy_dotfiles(options)
    end

    # puts Dir.children(TEST_DOTFILES).to_s + " dotfiles"
    # puts Dir.children(BACKUP_DIR).to_s + " backups"
    # puts Dir.children(DEST_DIR).to_s + " dests"
    # No backup should exist
    refute File.exist?(File.join(BACKUP_DIR, 'vimrc.orig'))
    assert File.exist?(File.join(DEST_DIR, '.vimrc'))
    assert File.exist?(File.join(TEST_DOTFILES, 'vimrc'))
  end

  def test_copy_dotfiles_copies_directories_properly
    skip
    log_method(LOGGER) do
      VpsCli::Copy.copy_dotfiles(BACKUP_DIR, DEST_DIR, TEST_DOTFILES)
    end
  end

  def test_raise_error_on_root_run
    # Stubbing process and dir mimic running as root
    Process.stub :uid, 0 do
      Dir.stub :home, '/root' do
        assert_raises(RuntimeError) { VpsCli::Copy.copy }
      end
    end
  end
end
