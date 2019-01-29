#!/bin/env ruby

require 'rake'

file_path = File.expand_path(__FILE__)
file_name = File.basename(__FILE__, '.rb')
bin_path = File.join(Dir.home, 'bin')
bin_file = File.join(bin_path, file_name)

# make file executable
Rake.chmod('+x', file_path, verbose: true)
# place link to ~/bin
Rake.ln_s(file_path, bin_file)

Rake.mkdir_p(bin_path)
# # adds ~/bin to your path in case its not already there
# Rake.sh("export PATH=#{bin_path}:$PATH")
