#!/usr/bin/ruby
# frozen_string_literal: true

lib = File.expand_path('lib')
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'vps_cli'

VpsCli::Cli.start(ARGV)
