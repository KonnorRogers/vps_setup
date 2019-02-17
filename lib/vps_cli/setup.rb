# frozen_string_literal: true

module VpsCli
  # Various setup to include ufw firewalls, adding repos, adding fonts etc
  class Setup
    def self.privileged_user?
      Process.uid.zero?
    end

    def self.root?
      privileged_user? && Dir.home == '/root'
    end

    def self.full
      add_repos
      add_dejavu_sans_mono_font
      add_snippets
    end

    ##
    # Sets up ufw for you to be able to have certain firewalls in place
    # Must be run after installing ufw
    # via sudo apt install ufw
    def self.ufw_setup
      Rake.sh('sudo ufw default deny incoming')
      Rake.sh('sudo ufw default allow outgoing')
      # allows ssh & mosh connections
      Rake.sh('sudo ufw allow 60000:61000/tcp')

      # Typical ssh port
      Rake.sh('sudo ufw allow 22')

      # Should you use Bastillion, the port used by the service
      Rake.sh('sudo ufw allow 8443')
      Rake.sh('yes | sudo ufw enable')
      Rake.sh('yes | sudo systemctl restart sshd')
    end

    ##
    # Adds repos to the package manager to be tracked
    # Adds the following repos:
    # docker, yarn
    # This method used to add neovim, asciinema, and mosh as well
    # But they are all part of the base ubuntu 18.10 release
    def self.add_repos
      add_docker_repo
      add_yarn_repo

      ## Now part of cosmic release for Ubuntu 18.10
      # add_neovim_repo
      # add_mosh_repo
      # add_asciinema_repo
    end

    def self.add_docker_repo
      # Instructions straight from https://docs.docker.com/install/linux/docker-ce/ubuntu/#set-up-the-repository
      # Docker repo
      Rake.sh('curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -')
      Rake.sh('sudo apt-key fingerprint 0EBFCD88')
      Rake.sh(%{yes "\n" | sudo add-apt-repository -y \
          "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
             $(lsb_release -cs) \
             stable"})
    end

    def self.add_yarn_repo
      # yarn repo
      Rake.sh(%( curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -))
      Rake.sh(%(echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list))
      Rake.sh('sudo apt update')
    end

    # @deprecated
    def self.add_neovim_repo
      # add neovim
      Rake.sh('sudo add-apt-repository ppa:neovim-ppa/stable')
    end

    # @deprecated
    def self.add_mosh_repo
      # mosh repo
      Rake.sh(%(yes "\n" | sudo add-apt-repository ppa:keithw/mosh))
    end

    # @deprecated
    def self.add_asciinema_repo
      # asciinema repo for recording the terminal
      Rake.sh('sudo apt-add-repository -y ppa:zanchey/asciinema')
    end

    def self.add_dejavu_sans_mono_font
      Rake.sh('mkdir -p ~/.local/share/fonts')
      Rake.sh(%(cd ~/.local/share/fonts && curl -fLo "DejaVu Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Regular/complete/DejaVu%20Sans%20Mono%20Nerd%20Font%20Complete%20Mono.ttf))
    end

    def self.add_snippets
      ultisnips_dir = File.join(Dir.home, 'ParamagicianUltiSnips')

      if Dir.exist?(ultisnips_dir)
        Dir.chdir(ultisnips_dir)
        ## Just in case anything is uncommitted
        Rake.sh('git add -A')
        Rake.sh("git commit -m 'commiting snippets'")
        Rake.sh('git pull')
      else

        Rake.sh("git clone https://github.com/ParamagicDev/ParamagicianUltiSnips.git #{ultisnips_dir}")
      end
    rescue RuntimeError => error
      message = 'something went wrong adding snippets, ensure everything is okay
      by running ~/ParamagicianUltiSnips'
      VpsCli.errors << error.exception("#{error}\n\n#{message}")

      Dir.chdir(Dir.home)
    end

    def self.git_config
      puts 'Please enter your git username:'
      username = $stdin.gets.chomp
      Rake.sh("git config --global user.name #{username}")

      puts 'Please enter your email:'
      email = $stdin.gets.chomp
      Rake.sh("git config --global user.email #{email}")

      puts "Git config complete.\n"
    rescue RuntimeError => error
      message = 'Something went wrong. Make sure to set your git config manually'

      VpsCli.errors << error.exception("#{error}\n\n#{message}")
    end

    def self.heroku_login
      puts 'Please login to heroku:'
      Rake.sh('heroku login --interactive')
    rescue RuntimeError => error
      message = "\n\nUnable not login to heroku. To login, type: 'heroku login'"
      VpsCli.errors << error.exception("#{error}\n\n#{message}")
    end
  end
end
