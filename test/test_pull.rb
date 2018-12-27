# frozen_string_literal: true

require 'test_helper'

SAMPLE_CONFIG_DIR = %w[cygwin_zshrc
                       gnome_terminal_settings
                       minttyrc
                       pryrc
                       sshd_config
                       tmux.conf
                       vimrc
                       zshrc].freeze

CYGWIN_CFG_DOTFILES = %w[cygwin_zshrc minttyrc pryrc tmux.conf vimrc]
LINUX_CFG_DOTFILES = %w[zshrc pryrc tmux.conf vimrc]

class TestPull < Minitest::Test
  include VpsSetup

  def setup; end

  def teardown; end

  # def test_linux_config_files_ary
  #   ary = Pull.linux_config_files_ary(SAMPLE_CONFIG_DIR)

  #   assert ary == LINUX_CFG_DOTFILES
  # end
end
