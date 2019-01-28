# frozen_string_literal: true

# require 'packages'
require 'os'

module VpsSetup
  OMZ_DIR = File.join(Dir.home, '.oh-my-zsh')
  OMZ_PLUGINS = File.join(OMZ_DIR, 'custom', 'plugins')
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
      neovim_pip
      omz_full_install
      Setup.ufw_setup
      plug_install_vim_neovim
    end

    def self.prep
      Rake.sh('sudo apt-get update')
      Rake.sh('sudo apt-get upgrade -y')
      Rake.sh('sudo apt-get dist-upgrade -y')
    end

    def self.packages
      Packages::UBUNTU.each do |item|
        Rake.sh("sudo apt-get install -y #{item}")

        puts 'Successfully completed apt-get install on all packages.'
      end
    end

    def self.other_tools
      # update npm, there are some issues with ubuntu 18.10 removing npm
      # and then being unable to update it
      Rake.sh('sudo npm install -g npm')

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

      # add docker
      username = Dir.home.split('/')[2]
      begin
        Rake.sh('groupadd docker')
        Rake.sh("usermod -aG docker #{username}")
      rescue RuntimeError
        puts 'docker group already exists.'
        puts 'moving on...'
      end
    end

    def self.neovim_pip
      Rake.sh('sudo -H pip2 install neovim --system')
      Rake.sh('sudo -H pip3 install neovim --system')
      Rake.sh(%(yes "\n" | sudo npm install -g neovim))
    end

    def self.omz_full_install
      install_oh_my_zsh
      install_syntax_highlighting
      install_autosuggestions
    end

    def self.install_oh_my_zsh
      return if Dir.exist?(OMZ_DIR)

      Rake.sh('git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh')
      Rake.sh(%(sudo usermod --shell /bin/zsh "$USER"))
    end

    def self.install_autosuggestions
      auto = File.join(OMZ_PLUGINS, 'zsh-autosuggestions')
      return if File.exist?(auto)

      Rake.sh("git clone https://github.com/zsh-users/zsh-autosuggestions #{auto}")
    end

    def self.install_syntax_highlighting
      syntax = File.join(OMZ_PLUGINS, 'zsh-syntax-highlighting')
      return if File.exist?(syntax)

      Rake.sh("git clone https://github.com/zsh-users/zsh-syntax-highlighting.git #{syntax}")
    end

    def self.plug_install_vim_neovim
      Rake.sh(%(vim +'PlugInstall --sync' +qa))
      Rake.sh(%(vim +'PlugUpdate --sync' +qa))
      Rake.sh(%(nvim +'PlugInstall --sync' +qa))
      Rake.sh(%(nvim +'PlugUpdate --sync' +qa))
    end

    ## This needs to be called after golang and zsh have been sourced
    def self.install_sops
      Rake.sh(%(go get -u go.mozilla.org/sops/cmd/sops))
    end
end
