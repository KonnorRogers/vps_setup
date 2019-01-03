# frozen_string_literal: true

require 'rake/testtask'

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'vps_setup'

def tilde_to_home_hash(rake_args)
  # Rake::TaskArguments.to_hash equivalent
  rake_args.to_hash.transform_values { |value| value.sub(/~/, Dir.home) }
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

task :make, %i[backup_dir dest_dir] => %w[config:setup install] do |_t, args|
  args.with_defaults(backup_dir: BACKUP_DIR, dest_dir: Dir.home)
  params = tilde_to_home_hash(args)

  Rake::Task['config:copy'].invoke(params[:backup_dir], params[:dest_dir])
end

task :install do
  VpsSetup::Install.full
end
