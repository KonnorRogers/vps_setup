#!/usr/bin/ruby

# frozen_string_literal: true

lib = File.expand_path(__dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'vps_cli/file_helper'
require 'vps_cli/access'
require 'vps_cli/cli'
require 'vps_cli/copy'
require 'vps_cli/install'
require 'vps_cli/packages'
require 'vps_cli/pull'
require 'vps_cli/setup'
require 'vps_cli/constants'

# Used for setting up a ubuntu environment
module VpsCli
  include VpsConstants

  # All constants can be found in the constants.rb file
  # @see VpsCli::FileConstants
  # @see VpsCli::DecryptionConstants
  ROOT = FileConstants::ROOT
  FILES_DIR = FileConstants::FILES_DIR
  DOTFILES_DIR = FileConstants::DOTFILES_DIR
  MISC_FILES_DIR = FileConstants::MISC_FILES_DIR
  BACKUP_FILES_DIR = FileConstants::BACKUP_FILES_DIR


  class << self
    # Used for loggings errors
    # same as self.errors && self.errors=(errors)
    # VpsCli.errors now accessible module wide
    attr_accessor :errors
  end

  # Creates an empty array of errors to push to
  @errors ||= []

  # Base set of options, will set the defaults for the various options
  # Take a hash due to people being able to set their own directories
  # @param [Hash] Takes the hash to modify
  # @return [Hash] Returns the options hash with the various options
  # Possible options:
  #   :backup_dir
  #   :local_dir
  #   :dotfiles_dir
  #   :misc_files_dir
  #   :local_sshd_config
  #   :verbose
  #   :testing
  def self.create_options(opts = {})
    opts[:backup_dir] ||= BACKUP_FILES_DIR
    opts[:local_dir] ||= Dir.home
    opts[:dotfiles_dir] ||= DOTFILES_DIR
    opts[:misc_files_dir] ||= MISC_FILES_DIR
    opts[:local_sshd_config] ||= '/etc/ssh/sshd_config'

    opts[:verbose] = false if opts[:verbose].nil?
    opts[:interactive] = true if opts[:interactive].nil?

    opts
  end

  def self.full_install(options = {})
    VpsCli::Setup.full
    VpsCli::Install.full
    VpsCli::Access.provide_credentials(options)
    VpsCli::Copy.all(options)
  end
end
