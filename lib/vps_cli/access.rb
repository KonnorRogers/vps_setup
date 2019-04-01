# frozen_string_literal: true

# @see https://ruby-doc.org/stdlib-2.6.0.preview2/libdoc/open3/rdoc/Open3.html
require 'open3'
require 'json'

module VpsCli
  # Used for various things related to logins, ssh keys, etc
  class Access
    extend FileHelper # provides acccess to the FileHelper.decrypt(file) method

    # logs into various things either via a .yaml file or via cmd line
    # @param yaml_file [File] The yaml file to be used.
    #   MUST BE ENCRYPTED VIA SOPS
    #   @see https://github.com/mozilla/sops
    #   @see VpsCli::FileHelper#decrypt
    def self.provide_credentials(yaml_file: nil, netrc_file: nil)
      return file_login(yaml_file, netrc_file) unless yaml_file.nil?

      command_line_login
    end

    def self.file_login(yaml_file:, netrc_file: nil)
      git_file_login(yaml_file: yaml_file)
      heroku_file_login(yaml_file: yaml_file, netrc_file: netrc_file)
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
      msg = 'Something went wrong. Make sure to set your .gitconfig manually'

      VpsCli.errors << error.exception("#{error}\n\n#{msg}")
    end

    def self.heroku_login
      puts 'Please login to heroku:'
      Rake.sh('heroku login --interactive')
    rescue RuntimeError => error
      message = "\nUnable not login to heroku. To login, type: 'heroku login'"
      VpsCli.errors << error.exception("#{error}\n\n#{message}")
    end

    # Logs into git by setting it in your .gitconfig file
    # @param yaml_file [File] Sets your git login via the values in your
    #   yaml_file
    # @return nil
    def self.git_file_login(yaml_file:)
      username_key = FileHelper.path_to_value(:github, :username)
      email_key = FileHelper.path_to_value(:github, :email)

      username = FileHelper.decrypt(yaml_file, username_key)
      email = FileHelper.decrypt(yaml_file, email_key)

      set_git_config(username, email)
    end

    # @todo create another method to pass the keys
    def self.heroku_file_login(yaml_file:, netrc_file: nil)
      api_string = heroku_api_string(yaml_file: yaml_file)
      git_string = heroku_git_string(yaml_file: yaml_file)

      netrc_string = api_string + "\n" + git_string

      netrc_file ||= File.join(Dir.home, '.netrc')
      write_to_netrc(netrc_file: netrc_file, string: netrc_string)
    end

    # retrieves the values of .netrc for heroku and creates a writable string
    # @return [String] Returns the string to be written to netrc
    def self.heroku_api_string(yaml_file:)
      # initial tree traversal in the .yaml file
      heroku_api = %i[heroku api]
      heroku_api_keys = %i[machine login password]

      make_string(base: heroku_api, keys: heroku_api_keys) do |path|
        FileHelper.decrypt(yaml_file: yaml_file, path: path)
      end
    end

    # retries the git values for heroku in your .yaml file
    # @return [String] Returns the string to be written to your netrc file
    def self.heroku_git_values
      heroku_git = %i[heroku git]
      heroku_git_keys = %i[machine login password]

      make_string(base: heroku_git, keys: heroku_git_keys) do |path|
        FileHelper.decrypt(yaml_file: yaml_file, path: path)
      end
    end

    # @!group Access Helper Methods

    def self.my_inject_with_count(array, &block)
      1.up_to(array.length) do |count|
        array.inject('') do |accum, element|
          block.call(accum, element, count)
        end
      end
    end

    def self.make_string(base:, keys:, &block)
      # iterates through the keys to provide a path to each array
      # essentialy is the equivalent of Hash.dig(:heroku, :api, :key)
      my_inject_with_count(keys) do |string, key, count|
        path = FileHelper.dig_for_path(base, key)

        value = block.call(path)
        value += "\n  " if count < keys.length
        string + value
      end
    end

    def self.write_to_netrc(netrc_file: nil, string:)
      Rake.mkdir_p(File.dirname(netrc_file))
      Rake.touch(netrc_file) unless File.exist?(netrc_file)
      netrc_error(netrc_file) && return unless File.writable?(netrc_file)

      begin
        File.write(netrc_file, string)
      rescue RuntimeError
        netrc_error(netrc_file)
      end
    end

    def self.netrc_error(netrc_file)
      error_msg = "Unable to write to your #{netrc_file}."
      VpsCli.errors << error_msg
    end
    # @!endgroup
  end
end
