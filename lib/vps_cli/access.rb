# frozen_string_literal: true

# @see https://ruby-doc.org/stdlib-2.6.0.preview2/libdoc/open3/rdoc/Open3.html
require 'open3'

module VpsCli
  class Access
    def provide_credentials(file)

    end

    def self.set_git_config
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
    # uses an access file via SOPS
    # SOPS is an encryption tool
    # @see https://github.com/mozilla/sops
    # It will decrypt the file, please use a .yaml file
    # @param file [File]
    #   The .yaml file encrypted with sops used to login to various accounts
    # @param keys [Array<String>] The keys of the value youre trying to decrypt
    #   Example: ["github", "username"]
    # @return [String] The value of key given in the .yaml file
    def self.decrypt(file, keys)
      # puts all keys into a ["key"] within the array
      keys.map! { |key| "[\"#{key}\"]" }
      sops_cmd = "sops -d --extract '#{keys.join}' #{file}"

      # this will return in the string form the value you were looking for
      Open3.capture3(sops_cmd)
    end
end
