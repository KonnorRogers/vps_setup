# frozen_string_literal: true

# require 'packages'
require 'os'

module VpsSetup
  # Installes the required packages
  class Install
    def self.full
      unless OS.linux?
        puts 'You are not running on linux. No packages installed.'
        return :not_installed
      end

      begin
        all_install
      rescue RuntimeError => exception
        warn exception.message
        raise "The above error was raised.
      Apt-get install (packages) / ruby and other tools not installed
      Please ensure you are using the apt package manager."
      else
        :installed
      end
    end

    def self.all_install
      prep
      packages
      other_tools
      ruby_all
    end

    def self.prep
      Rake.sh('sudo apt-get update')
      Rake.sh('sudo apt-get upgrade -y')
      Rake.sh('sudo apt-get autoremove -y')
    end

    def self.packages
      Packages::UBUNTU.each do |item|
        Rake.sh("sudo apt-get install -y #{item}")

        puts 'Successfully completed apt-get install on all packages.'
      end
    end

    def self.other_tools
      # add heroku
      Rake.sh('sudo snap install heroku --classic')
      # add tmux plugin manager
      tmp_plugins = File.join(Dir.home, '.tmux', 'plugins', 'tpm')
      unless Dir.exist?(tmp_plugins)
        Rake.mkdir_p(tmp_plugins)
        Rake.sh('git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm')
      end
      # add ngrok
      Rake.sh('sudo npm install --unsafe-perm -g ngrok')
    end

    def self.ruby_all
      temp_dir = File.join(Dir.home, '.tmp')

      install_ruby_install(temp_dir)
      install_chruby(temp_dir)

      Dir.chdir(Dir.home)
      # no need to repeat if its already installed
      Rake.sh('ruby-install ruby-2.5.1 --no-reinstall')
      gem_dir = File.join(Dir.home, '.gem', 'ruby', '2.5.1')
      Packages::GEMS.each do |gem|
        Rake.sh("gem install #{gem} --install-dir #{gem_dir}")
      end
    end

    def self.install_ruby_install(temp_dir)
      exists = 'ruby-install already installed. Skipping install.'
      return puts exists if File.exist?('/usr/local/bin/ruby-install')

      Dir.chdir(temp_dir)

      Rake.sh(%(wget -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz))
      Rake.sh('tar -xzvf ruby-install-0.7.0.tar.gz')
      Dir.chdir('ruby-install-0.7.0/')
      Rake.sh('sudo make install')

      Dir.chdir(dir)
    end

    def self.install_chruby(temp_dir)
      exists = 'chruby already installed. Skipping install.'
      return puts exists if File.exist?('/usr/local/share/chruby/chruby.sh')

      Dir.chdir(temp_dir)

      Rake.sh(%(wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz))
      Rake.sh('tar -xzvf chruby-0.3.9.tar.gz')
      Dir.chdir('chruby-0.3.9/')
      Rake.sh('sudo make install')

      # Reset back to temp_dir
      Dir.chdir(temp_dir)
    end
  end
end
