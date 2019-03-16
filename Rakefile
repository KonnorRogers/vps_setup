# frozen_string_literal: true

require 'rake/testtask'

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'vps_cli'

def tilde_to_home_hash(rake_args)
  # Rake::TaskArguments.to_hash equivalent
  rake_args.to_hash.map { |k, v| [k, v.sub('~', Dir.home)] }.to_h
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

# task :make, %i[backup_dir dest_dir] do |_t, args|
#   # Not necessary for babun
#   Rake::Task['setup'].invoke
#   Rake::Task['install'].invoke

#   args.with_defaults(backup_dir: BACKUP_DIR, dest_dir: Dir.home)
#   params = tilde_to_home_hash(args)

#   Rake::Task['config:copy'].invoke(params[:backup_dir], params[:dest_dir])
# end

# task :login do
#   VpsCli::Setup.git_config
#   VpsCli::Setup.heroku_login
# end

# task :install do
#   VpsCli::Install.full
#   sh('sudo apt-get autoremove -y')
# end

# task :setup do
#   VpsCli::Setup.full
# end

# task :example do
#   puts 'example'
# end
