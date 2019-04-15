# frozen_string_literal: true

module VpsCli
  class Packages
    LANGUAGES = %w[python3 python3-pip python-dev
                   python3-dev python-pip python3-neovim
                   nodejs golang ruby ruby-dev].freeze

    TOOLS = %w[curl tmux git vim zsh sqlite3 ctags rdoc
               openssh-client openssh-server dconf-cli gnome-terminal
               postgresql pry rubygems fail2ban node-gyp].freeze

    ADDED_REPOS = %w[neovim asciinema docker mosh yarn].freeze

<<<<<<< HEAD:lib/vps_cli/packages.rb
    GEMS = %w[colorls neovim rake pry rubocop gem-ctags].freeze
=======
    GEMS = %w[colorls neovim rake pry rubocop gem-ctags rails yard].freeze
>>>>>>> b87618d8e20f80e49d25405d40c6aeaaa3e142f9:lib/vps_cli/packages.rb

    UBUNTU = LANGUAGES.dup.concat(TOOLS).concat(ADDED_REPOS)
  end
end
