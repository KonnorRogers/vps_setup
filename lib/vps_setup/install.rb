# require 'packages'

module VpsSetup
  class Install
    def self.full
      prep
      packages
      other_tools
      ruby_all
    end

    def self.prep
      sh('sudo apt-get update')
      sh('sudo apt-get upgrade -y')
      sh('sudo apt-get autoremove -y')
    end

    def self.packages
      Packages::UBUNTU.each do |item|
        Rake.sh("sudo apt-get install -y #{item}")
      rescue => exception
        warn exception.message

        # reraise the error
        raise "apt-get install / apt install not working as intended. Ensure you are sudo and that you have this package manager."
      end

      puts "Successfully completed apt-get install on all packages."
    end

    def self.other_tools
      # add heroku
      Rake.sh('sudo snap install heroku --classic')
      # add tmux plugin manager
      Rake.mkdir_p(File.join(Dir.home, '.tmux', 'plugins'))
      Rake.sh('git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm')
      # add ngrok
      Rake.sh('sudo npm install --unsafe-perm -g ngrok')
    end

    def self.ruby_all
      temp_dir = File.join(Dir.home, '.tmp')

      install_ruby_install(temp_dir)
      install_chruby(temp_dir)

      Dir.chdir(Dir.home)
      Rake.sh('ruby-install ruby-2.5.1 --no-reinstall') # no need to repeat if its there
      gem_dir = File.join(Dir.home, '.gem', 'ruby', '2.5.1')
      GEMS.each { |gem| sh("gem install #{gem} --install-dir #{gem_dir}") }
    end

    def self.install_ruby_install(temp_dir)
      exists = 'ruby-install already installed. Skipping install.'
      return puts exists if File.exist?('/usr/local/bin/ruby-install')

      Dir.chdir(temp_dir)

      Rake.sh(%(wget -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz))
      Rake.sh("tar -xzvf ruby-install-0.7.0.tar.gz")
      Dir.chdir("ruby-install-0.7.0/")
      Rake.sh("sudo make install")

      Dir.chdir(dir)
    end

    def self.install_chruby(temp_dir)
      exists = 'chruby already installed. Skipping install.'
      return puts exists if File.exist?('/usr/local/share/chruby/chruby.sh')

      Dir.chdir(temp_dir)

      Rake.sh(%(wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz))
      Rake.sh("tar -xzvf chruby-0.3.9.tar.gz")
      Dir.chdir('chruby-0.3.9/')
      Rake.sh("sudo make install")

      # Reset back to temp_dir
      Dir.chdir(temp_dir)
    end
  end
end
