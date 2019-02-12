# frozen_string_literal: true

require 'test_helper'
require 'fileutils'

# The goal of testing all of this is to not touch the base config_files
# And to keep the test suite entirely independent
class TestCopy < Minitest::Test
  # @logger = create_logger(__FILE__)

  def setup
    @logger = create_logger(__FILE__)
    rm_dirs(BACKUP_DIR, DEST_DIR, TEST_DOTFILES)
    mk_dirs(BACKUP_DIR, DEST_DIR, TEST_DOTFILES)
  end

  def teardown
    rm_dirs(BACKUP_DIR, DEST_DIR, TEST_DOTFILES)
  end

  def test_copy_dotfiles_copies_files_properly
    log_methods(@logger) do
      add_files_to_dotfiles('vimrc', 'zshrc', 'pryrc')
      VpsCli::Copy.copy_dotfiles(BACKUP_DIR, DEST_DIR, TEST_DOTFILES)
    end

    assert_includes BACKUP_DIR, 'vimrc.orig'
    assert_includes DEST_DIR, '.vimrc'
  end

  def test_copy_dotfiles_copies_directories_properly
    skip
    log_method(@logger) do
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
