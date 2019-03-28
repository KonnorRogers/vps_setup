# frozen_string_literal: true

module VpsCli
  class Access
    # uses an access file via SOPS
    # SOPS is an encryption tool
    # @see https://github.com/mozilla/sops
    # It will decrypt the file, please use a .yaml file
    # @param file [File]
    #   The .yaml file encrypted with sops used to login to various accounts

    def self.use_access_file(file)

    end

    def self.git_config
      puts 'Please enter your git username:'
      username = $stdin.gets.chomp
      Rake.sh("git config --global user.name #{username}")

      puts 'Please enter your email:'
      email = $stdin.gets.chomp
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
  end
end
