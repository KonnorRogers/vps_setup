# frozen_string_literal: true

require 'rake/testtask'

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

desc 'Runs tests'
task :test do
  Rake::TestTask.new do |t|
    t.libs << 'lib'
    t.libs << 'test'
    t.test_files = FileList['test/test*.rb']
  end
end

task default: :test
