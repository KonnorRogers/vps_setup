# frozen_string_literal: true

# @see https://ruby-doc.org/stdlib-2.6.0.preview2/libdoc/open3/rdoc/Open3.html
require 'open3'

module VpsCli
  # Used for various things related to logins, ssh keys, etc
  class Access
    extend FileHelper # provides acccess to the FileHelper.FileHelper.decrypt(file) method

    # @see DecryptionConstants
    #   for further info on these constants
    # They are defined elsewhere in order to keep the file more concise
    # HEROKU_HASH = DecryptionConstants::HEROKU_HASH
    # GITHUB_HASH = DecryptionConstants::GITHUB_HASH

    # logs into various things either via a .yaml file or via cmd line
    # @param yaml_file [File] The yaml file to be used. MUST BE ENCRYPTED VIA SOPS
    #   @see https://github.com/mozilla/sops
    #   @see VpsCli::FileHelper#decrypt
    def self.provide_credentials(yaml_file: nil)
      return file_login(yaml_file) unless yaml_file.nil?

      command_line_login
    end


    def self.file_login(yaml_file:)

    end

    def self.command_line_login
      set_git_config
      heroku_login
    end

    def self.set_git_config(username = nil, email = nil)
      puts 'Please enter your git username:'
      username ||= $stdin.gets.chomp
      Rake.sh("git config --global user.name #{username}")

      puts 'Please enter your email:'
      email ||= $stdin.gets.chomp
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

    # @todo fix this so that it uses VpsCli::DecryptionConstants
    def self.git_file_login(yaml_file:)
      # username_key = GITHUB_HASH[:github][:username]
      # username = FileHelper.decrypt(yaml_file, username_key)
      # email = FileHelper.decrypt(yaml_file, email_key)

      # set_git_config(username, email)
    end

    # @todo create another method to pass the keys
    def self.heroku_file_login(yaml_file:, keys:)
      # heroku = 'heroku'
      # api = 'api'
      # FileHelper.decrypt(yaml_file)
    end

    # @param hash_name [Symbol, String] The name of the hash to be used
    #   as the top level for a yaml tree
    #   IE: if your yaml tree goes: ['heroku']['api']
    #   Then your hash_name is 'heroku'
    # @param keys [Array<Symbol>] The value of the keys in your tree
    #   IE: if your taml tree contains:
    #   ['heroku']['api'] and ['heroku']['api_login']
    #   Then your array of keys will look like this:
    #   [:api, :api_login]
    # @return [Hash<Symbol, String>] returns a hash easily decrypted
    #   by FileHelper#decrypt
    # @see VpsCli::FileHelper#decrypt
    def self.create_hash(hash_name, keys)
      decryption_hash = Hash.new do |hash, key|
        hash[key] = "[\"#{hash_name}\"][\"#{key}\"]"
      end

      keys.each { |key| decryption_hash[key] }

      decryption_hash
    end

    HEROKU_KEYS = %i[
    api api_login api_password
    git git_login git_password
    ]

    GITHUB_KEYS = %i[username email password api_token]

    # @todo move this somewhere
    HEROKU_HASH = create_hash(:heroku, HEROKU_KEYS)
    GITHUB_HASH = create_hash(:github, GITHUB_KEYS)
  end
end
