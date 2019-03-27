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

# Used for setting up a ubuntu environment
module VpsCli
  # @!group Top Level Constants

  # Project's Root Directory
  ROOT = File.expand_path(File.expand_path('../', __dir__))

  # Projects config_files directory
  FILES_DIR = File.join(ROOT, 'config_files')

  # Projects Dotfiles directory
  DOTFILES_DIR = File.join(FILES_DIR, 'dotfiles')

  # Miscellaneous files like sshd_config
  MISC_FILES_DIR = File.join(FILES_DIR, 'misc_files')

  # Directory of backup files
  BACKUP_FILES_DIR = File.join(Dir.home, 'backup_files')

  # @!endgroup

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
end

if ARGV[0].to_sym == :pull_all
  VpsCli::Pull.all
end

if ARGV[0].to_sym == :copy_all
  VpsCli::Copy.all
end
