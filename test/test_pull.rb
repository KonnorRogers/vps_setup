# frozen_string_literal: true

require 'test_helper'

SAMPLE_CONFIG_DIR =
  %w[cygwin_zshrc
     gnome_terminal_settings
     minttyrc
     pryrc
     sshd_config
     tmux.conf
     vimrc
     zshrc].freeze

SAMPLE_LINUX_HOME_DIR = %w[.zshrc .pryrc .tmux.conf .vimrc].freeze
SAMPLE_CYGWIN_HOME_DIR = %w[.zshrc .minttyrc .pryrc .tmux.conf .vimrc].freeze

CYGWIN_CFG_DOTFILES = %w[cygwin_zshrc minttyrc pryrc tmux.conf vimrc].freeze
LINUX_CFG_DOTFILES = %w[zshrc pryrc tmux.conf vimrc].freeze

class TestPull < Minitest::Test
  include VpsSetup

  def setup; end

  def teardown; end

  def test_linux_config_dotfiles_ary
    ary = Pull.linux_config_dotfiles_ary(SAMPLE_CONFIG_DIR)

    assert_equal(ary.sort, LINUX_CFG_DOTFILES.sort)
    # sorting doesnt matter, only used to ensure equality
    # alternatively
    # ary.each { |file| assert_includes(LINUX_CFG_DOTFILES, file) }
  end

  def test_cygwin_config_dotfiles_ary
    ary = Pull.cygwin_config_dotfiles_ary(SAMPLE_CONFIG_DIR)

    assert_equal(ary.sort, CYGWIN_CFG_DOTFILES)
  end

  def test_cygwin_local_dotfiles_ary
    ary = Pull.cygwin_local_dotfiles_ary(SAMPLE_HOME_DIR)
  end
end
