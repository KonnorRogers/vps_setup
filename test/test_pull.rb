# frozen_string_literal: true

require 'test_helper'

LOGGER = create_logger(__FILE__)

TEST_FILES = %w[vimrc pryrc zshrc].freeze
TEST_DIRS = %w[config dir2].freeze
SSHD_CONFIG = 'sshd_config'
GNOME_TERMINAL = 'gnome_terminal_settings'
# backup files not needed when pulling. Youre pulling into a git managed repo
BASE_DIRS = [LOCAL_DIR, TEST_DOTFILES, TEST_MISC_FILES].freeze

class TestPull < Minitest::Test
  def setup
    rm_dirs(BASE_DIRS)
    mk_dirs(BASE_DIRS)
  end

  def teardown
    rm_dirs(BASE_DIRS)
  end

  def create_local_and_remote_files
    # dotfiles
    add_files(LOCAL_DIR, TEST_FILES)
    add_dirs(LOCAL_DIR, TEST_DIRS)

    add_files(TEST_DOTFILES, TEST_FILES)
    add_dirs(TEST_DOTFILES, TEST_DIRS)

    # miscfiles
    add_files(LOCAL_DIR, SSHD_CONFIG)
    add_files(LOCAL_DIR, GNOME_TERMINAL)

    add_files(LOCAL_DIR, SSHD_CONFIG)
    add_files(LOCAL_DIR, GNOME_TERMINAL)
  end

  def write_to_file(file, string)
    File.open(file, 'w+') do
      puts string
    end
  end

  def test_create_local_and_remote_files
    assert_empty Dir.children(LOCAL_DIR)
    assert_empty Dir.children(TEST_DOTFILES)

    create_local_and_remote_files

    refute_empty Dir.children(LOCAL_DIR)
    refute_empty Dir.children(TEST_DOTFILES)
  end

  def test_pulls_dotfiles_properly
    create_local_and_remote_files

    log_methods(LOGGER) do
      VpsCli::Pull.dotfiles(test_options)
    end
  end

  def test_pulls_gnome_terminal_properly
    skip
  end
end
