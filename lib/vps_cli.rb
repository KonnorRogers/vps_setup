#!/usr/bin/ruby

# frozen_string_literal: true

lib = File.expand_path(__dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'vps_cli/copy'
require 'vps_cli/pull'
require 'vps_cli/setup'
require 'vps_cli/packages'
require 'vps_cli/install'
require 'vps_cli/cli'

# Used for setting up a ubuntu environment
module VpsCli
  # @!group  Top Level Constants

  # Project's Root Directory
  ROOT = File.expand_path(File.expand_path('../', __dir__))

  # Project's Config directory containing configuration files
  CONFIG_DIR = File.join(ROOT, 'config')
  # @!endgroup

  # Checks for "." and ".." files in Dir.entries
  # This is a work around for Dir.entries due to Dir.children not existing prior to Ruby 2.5
  #
  # @param file [String] The name of the file
  # @return [Boolean] true or false depending on the file name
  def blank_file?(file)
    return true if file =~ /\A\.{1,2}\Z/

    false
  end
end


VpsCli::CLI.start(ARGV)
