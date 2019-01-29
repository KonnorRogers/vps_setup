# frozen_string_literal: true

require 'vps_setup/copy'
require 'vps_setup/pull'
require 'vps_setup/setup'
require 'vps_setup/packages'
require 'vps_setup/install'
# Used for setting up a linux + cygwin environment for ssh purposes
module VpsSetup
  # top level constants
  ROOT = File.expand_path(File.expand_path('../', __dir__))
  CONFIG_DIR = File.join(ROOT, 'config')

  # Non dotfiles specified to allow easier adding of dotfiles
  # may make seperate dirs in the future

  # files that are NOT dotfiles
  NON_DOTFILES = %w[gnome_terminal_settings sshd_config].freeze

  # Files you do not want to be copied to Cygwin environment
  NON_CYGWIN_DOTFILES = %w[zshrc config zshenv].concat(NON_DOTFILES)

  # Files you do not want to be copied to Linux environment
  NON_LINUX_DOTFILES = %w[cygwin_zshrc minttyrc].concat(NON_DOTFILES)

  def blank_file?(file)
    return true if file =~ /\A\.{1,2}\Z/

    false
  end
end

