# frozen_string_literal: true

# require 'packages'

module VpsCli
  OMZ_DIR = File.join(Dir.home, '.oh-my-zsh')
  OMZ_PLUGINS = File.join(OMZ_DIR, 'custom', 'plugins')
  # Installes the required packages
  class Install
    def self.full
      unless OS.linux?
        puts 'You are not running on linux. No packages installed.'
        return
      end

      begin
        all_install
      rescue RuntimeError => exception
        VpsCli.errors << exception
      end
    end

    def self.all_install
      prep
      packages
      other_tools
      neovim_pip
      omz_full_install
      Setup.full
      install_tmux_plugin_manager_and_plugins
      plug_install_vim_neovim
      install_gems
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
      Rake.sh('sudo apt-get install nodejs -y')
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

    def self.install_tmux_plugin_manager_and_plugins
      install_path = File.join(Dir.home, '.tmux', 'plugins', 'tpm')
      unless File.exist?(install_path)
        Rake.mkdir_p(install_path)
        Rake.sh("git clone https://github.com/tmux-plugins/tpm #{instal_path}")
      end
      # start a server but don't attach to it
      Rake.sh('tmux start-server')
      # create a new session but don't attach to it either
      Rake.sh('tmux new-session -d')
      # install the plugins
      Rake.sh('~/.tmux/plugins/tpm/scripts/install_plugins.sh')
      # killing the server is not required, I guess
      Rake.sh('tmux kill-server')
    end

    def self.install_gems
      Packages::GEMS.each { |g| Rake.sh("gem install #{g}") }
    end
  end
end
