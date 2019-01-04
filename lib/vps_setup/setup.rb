# frozen_string_literal: true

module VpsSetup
  class Setup
    def self.privileged_user?
      Process.uid.zero?
    end

    def self.root?
      privileged_user? && Dir.home == '/root'
    end

    def self.full
      adduser if root?
      ufw_setup
      add_repos
      add_dejavu_sans_mono_font
      add_snippets
      git config
      heroku_login
    end

    def self.adduser
      raise 'You are not sudo / root, unable to add user' unless privileged_user?

      puts 'Please create a user to run this script as:'
      username = gets.chomp
      Rake.sh("sudo adduser #{username}")
      Rake.sh("sudo adduser #{username} sudo")

      puts 'Please login as the new user and rerun the script as sudo.'
      Rake.sh("su #{username}")
    end

    def self.ufw_setup
      raise 'Not running as sudo' unless privileged_user?

      Rake.sh('sudo ufw default allow outgoing')
      Rake.sh('sudo ufw default deny incoming')
      Rake.sh('sudo ufw allow 60000:61000/tcp')
      Rake.sh('sudo ufw enable')
      Rake.sh('yes | sudo systemctl restart sshd')
    end

    def self.add_repos
      raise 'Not running as sudo' unless privileged_user?

      # neovim repo
      Rake.sh('sudo apt-add-repository -y ppa:neovim-ppa/stable')
      # asciinema repo for recording the terminal
      Rake.sh('sudo apt-add-repository -y ppa:zanchey/asciinema')
      # mosh repo
      Rake.sh(%(yes "\n" | sudo add-apt-repository ppa:keithw/mosh))

      # Instructions straight from https://docs.docker.com/install/linux/docker-ce/ubuntu/#set-up-the-repository
      # Docker repo
      Rake.sh('curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -')
      Rake.sh('sudo apt-key fingerprint 0EBFCD88')
      Rake.sh(%{yes "\n" | sudo add-apt-repository -y \
          "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
             $(lsb_release -cs) \
             stable"})
      # yarn repo

      Rake.sh(%( curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -))
      Rake.sh(%(echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list))
      Rake.sh('sudo apt update')
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
    rescue RuntimeError
      puts 'something went wrong adding snippets, ensure everything is okay'
      puts 'by running ~/ParamagicianUltiSnips'

      Dir.chdir(Dir.home)
    end

    def self.git_config
      puts 'Please enter your git username:'
      username = gets.chomp
      Rake.sh("git config --global user.name #{username}")

      puts 'Please enter your email:'
      email = gets.chomp
      Rake.sh("git config --global user.email #{email}")

      puts "Git config complete.\n"
    end

    def self.heroku_login
      puts 'Please login to heroku:'
      Rake.sh('heroku login')
    end
  end
end
