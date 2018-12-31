# frozen_string_literal: true

LIBS = %w[software-properties-common gnupg2 less ufw
          ack-grep libfuse2 apt-transport-https
          ca-certificates build-essential bison
          zlib1g-dev libyaml-dev libssl-dev
          libgdbm-dev libreadline-dev libffi-dev fuse make gcc].freeze

LANGUAGES = %w[python3 python3-pip python-dev
               python3-dev python-pip python3-neovim
               nodejs golang ruby ruby-dev].freeze

TOOLS = %w[curl tmux git vim zsh sqlite3
           postgresql pry rubygems fail2ban].freeze

ADDED_REPOS = %w[neovim asciinema docker-ce mosh].freeze
PACKAGE_LIST = LIBS.concat(LANGUAGES).concat(TOOLS).concat(ADDED_REPOS)

GEMS = %w[bundler rails colorls neovim rake pry]

namespace :setup do
  task :all_tasks [:add_user, :apt_all, :add_other_tools,:additional_ruby_install] do

  end

  task :add_user, [:username] do
    return if not_sudo_error
    return puts "#{username} is already taken" if Dir.exist?("/home/#{username}")

    sh("adduser #{username}")
    sh("adduser #{username} sudo")
  end

  task :apt_all, [:add_repos] do
    PACKAGE_LIST.each do |item|
      sh("sudo apt install -y #{item}")
    end
  end

  task :additional_ruby_install do
    install_ruby_install
    install_chruby
    sh('ruby-install ruby-2.5.1 --no-reinstall')
    
    gem_dir = File.join(Dir.home, '.gem', 'ruby', '2.5.1')
    GEMS.each { |gem| sh("gem install #{gem} --install-dir #{gem_dir}") }
  end

  task :add_other_tools do
    # add heroku
    sh('sudo snap install heroku --classic')

    # add tmux plugin manager
    sh('git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm')

    # add ngrok
    sh('sudo npm install --unsafe-perm -g ngrok')
  end

  task :apt_prep do
    return if not_sudo_error

    sh('sudo apt-get update')
    sh('sudo apt-get upgrade -y')
    sh('sudo apt-get autoremove -y')
  end

  task :add_repos, [:apt_prep] do
    sh('sudo apt-add-repository -y ppa:neovim-ppa/stable')
    sh('sudo apt-add-repository -y ppa:zanchey/asciinema')
    sh(%(yes "\n" | sudo add-apt-repository ppa:keithw/mosh))
    # Instructions straight from https://docs.docker.com/install/linux/docker-ce/ubuntu/#set-up-the-repository
    sh('curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -')
    sh('sudo apt-key fingerprint 0EBFCD88')
    sh(%{yes "\n" | sudo add-apt-repository -y \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"})
    # yarn
    sh('curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -')
    sh(%(echo "deb https://dl.yarnpkg.com/debian/ stable main"
       | sudo tee /etc/apt/sources.list.d/yarn.list))

    sh('sudo apt update')
  end
end

def not_sudo_error
    not_sudo 'You are not running as sudo, unable to add a user'
    raise not_sudo unless Process.uid.zero

    true
end

def install_chruby
  sh(%(if [[ -e /usr/local/share/chruby/chruby.sh ]]; then
        echo 'chruby is already installed'
    else
        wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
        tar -xzvf chruby-0.3.9.tar.gz
        cd chruby-0.3.9/
        sudo make install
    fi))
end

def install_ruby_install
  sh(%{if [[ $"(command -v ruby-install)" ]]; then
        echo 'ruby-install is already installed'
    else
        wget -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz
        tar -xzvf ruby-install-0.7.0.tar.gz
        cd ruby-install-0.7.0/
        sudo make install
    fi})
end
