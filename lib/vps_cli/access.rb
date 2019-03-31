# frozen_string_literal: true

# @see https://ruby-doc.org/stdlib-2.6.0.preview2/libdoc/open3/rdoc/Open3.html
require 'open3'
require 'vps_constants'

module VpsCli
  # Used for various things related to logins, ssh keys, etc
  class Access
    extend FileHelper # provides acccess to the FileHelper.FileHelper.decrypt(file) method
    include VpsConstants

    # @see VpsConstants for further info on these constants
    # They are defined in order to keep the file more concise
    HEROKU_HASH = VpsConstants::HEROKU_HASH
    GITHUB_HASH = VpsConstants::GITHUB_HASH

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

    def self.git_file_login(yaml_file:)
      github = 'github'
      username_key = ['username'].unshift(github)
      email_key = ['email'].unshift(github)

      username = FileHelper.decrypt(yaml_file, username_key)
      email = FileHelper.decrypt(yaml_file, email_key)

      set_git_config(username, email)
    end

    # @todo create another method to pass the keys
    def self.heroku_file_login(yaml_file:, keys:)
      heroku = 'heroku'
      api = 'api'
      FileHelper.decrypt(yaml_file)
    end
  end
end
