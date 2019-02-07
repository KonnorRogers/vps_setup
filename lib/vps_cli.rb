#!/usr/bin/ruby

# frozen_string_literal: true

lib = File.expand_path(__dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

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

  # Project's Config directory containing configuration files
  DOTFILES_DIR = File.join(ROOT, 'dotfiles')
  MISC_DIR = File.join(ROOT, 'miscfiles')
  # @!endgroup

  class << self
    # Used for loggings errors
    # same as self.errors && self.errors=(errors)
    # VpsCli.errors now accessible module wide
    attr_accessor :errors
  end

  @errors ||= []
end

VpsCli::CLI.start(ARGV)
