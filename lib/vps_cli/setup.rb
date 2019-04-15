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
      ufw_setup
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
  end
end
