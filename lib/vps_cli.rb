#!/usr/bin/env ruby

# frozen_string_literal: true

require 'vps_cli/copy'
require 'vps_cli/pull'
require 'vps_cli/setup'
require 'vps_cli/packages'
require 'vps_cli/install'
# Used for setting up a linux + cygwin environment for ssh purposes
module VpsCli
  # top level constants
  ROOT = File.expand_path(File.expand_path('../', __dir__))
  CONFIG_DIR = File.join(ROOT, 'config')

  # Non dotfiles specified to allow easier adding of dotfiles
  # may make seperate dirs in the future

  # files that are NOT dotfiles
  NON_DOTFILES = %w[gnome_terminal_settings sshd_config].freeze

  def blank_file?(file)
    return true if file =~ /\A\.{1,2}\Z/

    false
  end
end

