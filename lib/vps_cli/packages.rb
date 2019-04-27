# frozen_string_literal: true

module VpsCli
  class Packages
    LANGUAGES = %w[python3 python3-pip python-dev
                   python3-dev python-pip python3-neovim
                   nodejs golang ruby ruby-dev].freeze

    TOOLS = %w[curl tmux git vim zsh sqlite3 ctags rdoc libsqlite3-dev
               openssh-client openssh-server dconf-cli gnome-terminal
               postgresql pry rubygems fail2ban node-gyp
               libcurl4-openssl-dev libxml2-dev].freeze

    ADDED_REPOS = %w[neovim asciinema docker mosh yarn].freeze

    GEMS = %w[colorls neovim rake pry
              rubocop gem-ctags rails yard
              thor bundler].freeze

    UBUNTU = LANGUAGES.dup.concat(TOOLS).concat(ADDED_REPOS)
  end
end
