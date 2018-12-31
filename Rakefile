# frozen_string_literal: true

require 'rake/testtask'

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'vps_setup'

def tilde_to_home(*args)
  # turns ~ into /home/user, must be given a hash
  return if args.nil? || args.empty?
  args.each do |key, string|
    args[key] = string.sub('~', Dir.home)
  end
end

task default: %w[test]

desc 'Runs tests'
task :test do
  Rake::TestTask.new do |t|
    t.libs << 'lib'
    t.libs << 'test'
    t.test_files = FileList['test/test*.rb']
  end
end

task :example do
  # puts Process.uid
  # puts Dir.home
end
