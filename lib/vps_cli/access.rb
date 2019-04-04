# frozen_string_literal: true

# @see https://ruby-doc.org/stdlib-2.6.0.preview2/libdoc/open3/rdoc/Open3.html
require 'open3'
require 'json'

module VpsCli
  # Used for various things related to logins, ssh keys, etc
  class Access
    # logs into various things either via a .yaml file or via cmd line
    # @param yaml_file [File] The yaml file to be used.
    #   MUST BE ENCRYPTED VIA SOPS
    #   @see https://github.com/mozilla/sops
    #   @see VpsCli::Access#decrypt
    # @return void
    def self.provide_credentials(yaml_file: nil, netrc_file: nil)
      return file_login(yaml_file, netrc_file) unless yaml_file.nil?

      command_line_login
    end

    # Provides all login credentials via a SOPS encrypted yaml file
    # @param yaml_file [File] File formatted in yaml and encrypted with SOPS
    # @param netrc_file [File] ($HOME/.netrc) Location of the .netrc for heroku
    # @return void
    def self.file_login(yaml_file:, netrc_file: nil)
      netrc_file ||= File.join(Dir.home, '.netrc')
      git_file_login(yaml_file: yaml_file)
      heroku_file_login(yaml_file: yaml_file, netrc_file: netrc_file)
    end

    # Logs in via the command line if no yaml_file given
    def self.command_line_login
      set_git_config
      heroku_login
    end

    # Sets the .gitconfig file
    # @param username [String] Username to set in .gitconfig
    # @param email [String] email to use for .gitconfig
    # @return void
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

    # Command line heroku login
    # @return void
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
      username_key = path_to_value(:github, :username)
      email_key = path_to_value(:github, :email)

      username = decrypt(yaml_file, username_key)
      email = decrypt(yaml_file, email_key)

      set_git_config(username, email)
    end

    # Logs into heroku if given an encrypted yaml_file
    # @param yaml_file [File] The yaml file to be decrypted
    # @param netrc_file [File] The netrc file to write to
    # @return void
    def self.heroku_file_login(yaml_file:, netrc_file: nil)
      netrc_file ||= File.join(Dir.home, '.netrc')

      api_string = heroku_api_string(yaml_file: yaml_file)
      git_string = heroku_git_string(yaml_file: yaml_file)

      netrc_string = api_string + "\n" + git_string

      write_to_netrc(netrc_file: netrc_file, string: netrc_string)
    end

    # retrieves the values of .netrc for heroku and creates a writable string
    # @return [String] Returns the string to be written to netrc
    def self.heroku_api_string(yaml_file:)
      # initial tree traversal in the .yaml file
      heroku_api = %i[heroku api]
      heroku_api_keys = %i[machine login password]

      make_string(base: heroku_api, keys: heroku_api_keys) do |path|
        decrypt(yaml_file: yaml_file, path: path)
      end
    end

    # retries the git values for heroku in your .yaml file
    # @return [String] Returns the string to be written to your netrc file
    def self.heroku_git_string(yaml_file:)
      heroku_git = %i[heroku git]
      heroku_git_keys = %i[machine login password]

      make_string(base: heroku_git, keys: heroku_git_keys) do |path|
        decrypt(yaml_file: yaml_file, path: path)
      end
    end

    # @!group Access Helper Methods

    # my version of Enumerable#inject intended to return a string
    # provides a count to know what # object youre on
    # @param array [Array<#to_s>]
    #   For each element in the array, yield to the block given.
    # @yieldparam accum [String]
    #   The value that will persist throughout the block
    # @yieldparam element [String] The current element in the array
    # @yield param count [Integer]
    # @return [String] Returns the string returned by the block passed to it
    def self.my_inject_with_count(array, &block)
      value = nil
      count = 0
      array.inject('') do |accum, element|
        value = block.call(accum, element, count)
        count += 1
        value # if not here, returns the value of count
      end
    end

    # Creates a string to be used to write to .netrc
    # @param base [String] Provides the base string from which to add to
    # @param keys [Array<String>] An array of strings to append to base
    # @return [String] Returns the string after concatenating them
    def self.make_string(base:, keys:, &block)
      # iterates through the keys to provide a path to each array
      # essentialy is the equivalent of Hash.dig(:heroku, :api, :key)
      my_inject_with_count(keys) do |string, key, count|
        path = dig_for_path(base, key)

        value = block.call(path)
        value << "\n  " if count < keys.length - 1
        string + value
      end
    end

    # Writes the value of string to netrc
    # @param netrc_file [File] ($HOME/.netrc)
    #   The location of your .netrc file to be read by heroku
    # @param string [String] The String to write to the netrc file
    # @return void
    def self.write_to_netrc(netrc_file: nil, string:)
      netrc_file ||= File.join(Dir.home, '.netrc')
      Rake.mkdir_p(File.dirname(netrc_file))
      Rake.touch(netrc_file) unless File.exist?(netrc_file)

      begin
        File.write(netrc_file, string)
      rescue Errno::EACCES => e
        netrc_error(netrc_file: netrc_file, error: e)
      end
    end

    # Adds the error to VpsCli#errors array
    # @param [File] Location of netrc_file
    # @param [Exception] The error to write to the array
    # @return void
    def self.netrc_error(netrc_file:, error:)
      error_msg = "Unable to write to your #{netrc_file}."
      VpsCli.errors << error.exception(error_msg)
    end

    # uses an access file via SOPS
    # SOPS is an encryption tool
    # @see https://github.com/mozilla/sops
    # It will decrypt the file, please use a .yaml file
    # @param file [File]
    #   The .yaml file encrypted with sops used to login to various accounts
    # @path [String] JSON formatted string to traverse
    #   a yaml file tree
    #   Example: "[\"github\"][\"username\"]"
    # @return [String] The value of key given in the .yaml file
    def self.decrypt(yaml_file:, path:)
      # puts all keys into a ["key"] within the array
      sops_cmd = "sops -d --extract '#{path}' #{yaml_file}"

      # this allows you to enter your passphrase
      export_tty
      # this will return in the string form the value you were looking for
      stdout, _stderr, _status = Open3.capture3(sops_cmd)

      stdout
    end

    # @param [#to_s, Array<#to_s>] The ordered path to traverse
    # @return [String] Returns a path string to be able to traverse a yaml file
    # @see VpsCli::Access#decrypt
    def self.dig_for_path(*path)
      path.flatten.inject('') do |final_path, node|
        final_path + "[#{node.to_s.to_json}]"
      end
    end

    # I noticed needing to export $(tty) while troubleshooting
    # issues with gpg keys. It is here just in case its not in
    # your zshrc / bashrc file
    # @return void
    def self.export_tty
      Rake.sh('GPG_TTY=$(tty) && export GPG_TTY')
    end
    # @!endgroup
  end
end
