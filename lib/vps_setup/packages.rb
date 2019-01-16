# frozen_string_literal: true

module VpsSetup
  class Packages
    LIBS = %w[software-properties-common gnupg2 less ufw npm
              ack-grep libfuse2 apt-transport-https
              ca-certificates build-essential bison
              zlib1g-dev libyaml-dev libssl-dev
              libgdbm-dev libreadline-dev libffi-dev fuse make gcc].freeze

    LANGUAGES = %w[python3 python3-pip python-dev
                   python3-dev python-pip python3-neovim
                   nodejs golang ruby ruby-dev].freeze

    TOOLS = %w[curl tmux git vim zsh sqlite3
               openssh-client openssh-server
               postgresql pry rubygems fail2ban].freeze

    ADDED_REPOS = %w[neovim asciinema docker-ce mosh yarn].freeze

    # Does not include gems
    UBUNTU = LIBS.dup.concat(LANGUAGES).concat(TOOLS).concat(ADDED_REPOS)
  end
end
