## frozen_string_literal: true

module VpsSetup
  class Packages
    LANGUAGES = %w[python3 python3-pip python-dev
                   python3-dev python-pip python3-neovim
                   nodejs golang ruby ruby-dev].freeze

    TOOLS = %w[curl tmux git vim zsh sqlite3
               openssh-client openssh-server
               postgresql pry rubygems fail2ban].freeze

    ADDED_REPOS = %w[neovim asciinema docker-ce mosh yarn].freeze

    # Does not include gems
    UBUNTU = LANGUAGES.dup.concat(TOOLS).concat(ADDED_REPOS)
  end
end
