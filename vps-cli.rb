#!/usr/bin/env ruby

lib = File.expand_path('lib')
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'vps_cli'

VpsCli::CLI.start(ARGV)
