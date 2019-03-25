# frozen_string_literal: true

require 'test_helper'


class TestPull < Minitest::Test
  @@logger = create_logger(__FILE__)
  @@test_files = %w[vimrc pryrc zshrc].freeze
  @@test_dirs = %w[config dir2].freeze
  @@sshd_config = 'sshd_config'
  @@gnome_terminal = 'gnome_terminal_settings'
  # backup files not needed when pulling. Youre pulling into a git managed repo
  @@base_dirs = [LOCAL_DIR, TEST_DOTFILES, TEST_MISC_FILES].freeze

  def setup
    rm_dirs(@@base_dirs)
    mk_dirs(@@base_dirs)
  end

  def teardown
    rm_dirs(@@base_dirs)
  end

  def create_local_and_remote_files
    # dotfiles
    add_files(LOCAL_DIR, @@test_files)
    add_dirs(LOCAL_DIR, @@test_dirs)

    add_files(TEST_DOTFILES, @@test_files)
    add_dirs(TEST_DOTFILES, @@test_dirs)

    # miscfiles
    add_files(LOCAL_DIR, @@sshd_config)
    add_files(LOCAL_DIR, @@gnome_terminal)

    add_files(LOCAL_DIR, @@sshd_config)
    add_files(LOCAL_DIR, @@gnome_terminal)
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

    log_methods(@@logger) do
      VpsCli::Pull.dotfiles(test_options)
    end
  end

  def test_pulls_gnome_terminal_properly
    skip
  end
end
