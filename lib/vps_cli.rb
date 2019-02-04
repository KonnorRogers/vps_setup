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

  ##
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

