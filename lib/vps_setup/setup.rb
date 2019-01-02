# frozen_string_literal: true

module VpsSetup
  class Setup
    def privileged_user?
      Process.uid.zero?
    end
    #packagetask rake tar
    def self.add_user(name = nil)
      raise "Not a privilieged user" unless privileged_user?

      name ||= retrieve_name

      if Dir.exist?("/home/#{name}")
        puts "#{name is already taken}"
        return :taken
      end

      #######################################
      #  This only works on a ubuntu system #
      #######################################

      # creates user
      Rake.sh("adduser #{name}")
      # makes a user a sudo user by adding them to the sudo group
      Rake.sh("adduser #{name} sudo")
    end

    def self.swap_user(name = nil)
      #######################################
      #  This only works on a ubuntu system #
      #######################################
      name ||= retrieve_name

      # changes user to the provided name. Will prompt for password
      loop do
        Rake.sh("su #{name}")
      rescue
        puts "Something went wrong. Please reenter your password:"
      else
        puts "Authentication successful"
        break
      end
      # This will swap the user and end the program

    end

    def self.retrieve_name
      puts "Please enter a username to be used:"
      gets.chomp
    end
  end
end
# namespace :setup do
#   task :ubuntu, [:username] => %i[swap_user apt_all add_other_tools ruby_install] do |_t, args|

#   end

#   task :add_user, [:username] do |_t, args|
#     return if not_sudo_error

#     args.with_defaults(username: gets.chomp)
#     return puts "#{username} is already taken" if Dir.exist?("/home/#{username}")

#     sh("adduser #{args.username}")
#     sh("adduser #{args.username} sudo")
#   end

#   task :swap_user, [:username] => :add_user do |t, args|
#     return unless Process.uid.zero? && Dir.home == '/root'

#     sh("su #{args.username}")
#   end

#   task :apt_all, [:add_repos] do
#     PACKAGES.each do |item|
#       sh("sudo apt install -y #{item}")
#     end
#   end

#   task :ruby_install do
#     install_ruby_install
#     install_chruby
#     sh('ruby-install ruby-2.5.1 --no-reinstall')

#     # may move to initial bundle bash script
#     gem_dir = File.join(Dir.home, '.gem', 'ruby', '2.5.1')
#     GEMS.each { |gem| sh("gem install #{gem} --install-dir #{gem_dir}") }
#   end

#   task :add_other_tools do
#     # add heroku
#     sh('sudo snap install heroku --classic')

#     # add tmux plugin manager
#     sh('git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm')

#     # add ngrok
#     sh('sudo npm install --unsafe-perm -g ngrok')
#   end

#   task :apt_prep do
#     return if not_sudo_error

#     sh('sudo apt-get update')
#     sh('sudo apt-get upgrade -y')
#     sh('sudo apt-get autoremove -y')
#   end

#   task :add_repos, [:apt_prep] do
#     sh('sudo apt-add-repository -y ppa:neovim-ppa/stable')
#     sh('sudo apt-add-repository -y ppa:zanchey/asciinema')
#     sh(%(yes "\n" | sudo add-apt-repository ppa:keithw/mosh))
#     # Instructions straight from https://docs.docker.com/install/linux/docker-ce/ubuntu/#set-up-the-repository
#     sh('curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -')
#     sh('sudo apt-key fingerprint 0EBFCD88')
#     sh(%{yes "\n" | sudo add-apt-repository -y \
#     "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#        $(lsb_release -cs) \
#        stable"})
#     # yarn
#     sh('curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -')
#     sh(%(echo "deb https://dl.yarnpkg.com/debian/ stable main"
#        | sudo tee /etc/apt/sources.list.d/yarn.list))

#     sh('sudo apt update')
#   end

#   def not_sudo_error
#     not_sudo = 'You are not running as sudo, unable to add a user'
#     raise not_sudo unless Process.uid.zero?

#     true
#   end

#   def install_chruby
#     exists = 'chruby already installed. Skipping install.'
#     return puts exists if File.exist?('/usr/local/share/chruby/chruby.sh')

#     temp_dir = File.join(Dir.home, '.tmp')
#     mkdir_p(temp_dir)
#     Dir.chdir(temp_dir)

#     sh(%(wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
#       tar -xzvf chruby-0.3.9.tar.gz
#       cd chruby-0.3.9/
#       sudo make install))

#     Dir.chdir(Dir.home)
#   end

#   def install_ruby_install
#     exists = 'ruby-install already installed. Skipping install.'
#     return puts exists if File.exist?('/usr/local/bin/ruby-install')

#     temp_dir = File.join(Dir.home, '.tmp')
#     mkdir_p(temp_dir)
#     Dir.chdir(temp_dir)
#     sh(%(wget -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz
#         tar -xzvf ruby-install-0.7.0.tar.gz
#         cd ruby-install-0.7.0/
#         sudo make install))

#     Dir.chdir(Dir.home)
#   end
# end
