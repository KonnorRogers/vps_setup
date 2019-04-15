# frozen_string_literal: true

# @see https://ruby-doc.org/stdlib-2.6.0.preview2/libdoc/open3/rdoc/Open3.html
require 'open3'
require 'json'
require 'vps_cli/access_helper'
require 'vps_cli/github_http'

module VpsCli
  # Used for various things related to logins, ssh keys, etc
  class Access
    extend AccessHelper
    # logs into various things either via a .yaml file or via cmd line
    # @param opts [Hash] For a full list of options view the following method:
    # @option opts [File] :netrc_file (~/.netrc) Default spot to write netrc
    # @option opts [String] :ssh_title (nil) the name for your ssh key
    # The following values are pulled from: @see #generate_ssh_key
    # @option opts [String] :type ('rsa') What kind of encryption
    #   You want for your ssh key
    # @option opts [Fixnum] :bits (4096) Strength of encryption
    # @option opts [String] :email (#get_email) The email comment
    #   to add to the end of the ssh key
    # @option opts [String, File] :output_file (~/.ssh/id_rsa)
    #   Where you want the key to be saved
    # @option opts [Boolean] :create_password (nil)
    #   if true, prompt to create a password
    # @option opts [File] :yaml_file (~/.credentials.yaml) The yaml file to be used.
    #   MUST BE ENCRYPTED VIA SOPS
    #   @see https://github.com/mozilla/sops
    #   @see VpsCli::Access#decrypt
    #   @see https://github.com/settings/tokens
    #     I prefer to use authentication tokens versus sending
    #     regular access info
    # @return void
    def self.provide_credentials(yaml_file: nil, netrc_file: nil, **opts)
      if yaml_file
        file_login(yaml_file, netrc_file)
      else
        command_line_login
      end

      generate_ssh_key(opts)
      post_github_ssh_key(opts)
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

    # Generates an ssh key with the given values for opts
    # this has not been extensively tested by myself so proceed with caution
    # @param opts [Hash] Options hash
    # @option opts [String] :type ('rsa') What kind of encryption
    #   You want for your ssh key
    # @option opts [Fixnum] :bits (4096) Strength of encryption
    # @option opts [String] :email (#get_email) The email comment
    #   to add to the end of the ssh key
    # @option opts [String, File] :output_file (~/.ssh/id_rsa)
    #   Where you want the key to be saved
    # @option opts [Boolean] :create_password (nil)
    #   if true, prompt to create a password
    def self.generate_ssh_key(**opts)
      type = opts[:type] ||= 'rsa'
      bits = opts[:bits] ||= 4096
      email = opts[:email] ||= get_email
      o_file = opts[:output_file] ||= File.join(Dir.home, '.ssh', 'id_rsa')

      no_pass = ' -P ""' unless opts[:create_password]

      # if opts[:create_password] is false, make a blank password
      # if its true, go through ssh-keygen
      # this will also autoprompt overwrite as well
      cmd = "ssh-keygen -t #{type} -b #{bits} -C #{email} -f #{o_file}#{no_pass}"
      Rake.sh(cmd)
    end

    # the wrapper around the GithubHTTP class to be able to send the ssh key
    # @param opts [Hash] Options parameter meant for cli usage
    # @option opts [String] :uri (URI('https://api.github.com/user/keys'))
    #   url of the api youd like to hit
    # @option opts [File] :yaml_file (nil) the file to decrypt values with.
    #
    def self.post_github_ssh_key(opts = {})
      uri = opts[:uri] ||= URI('https://api.github.com/user/keys')

      default_yaml_file = File.join(Dir.home, '.credentials.yaml')
      yaml_file = opts[:yaml_file] ||= default_yaml_file

      api_token = proc do |yaml, path|
        decrypt(yaml_file: yaml, path: path)
      end

      api_path = dig_for_path(:github, :api_token)

      token = opts[:api_token] ||= api_token.call(yaml_file, api_path)
      ssh_file = opts[:ssh_file] ||= File.join(Dir.home, '.ssh', 'id_rsa.pub')
      title = opts[:title] ||= get_title

      github = GithubHTTP.new(uri: uri, token: token,
                              ssh_file: ssh_file, title: title)
      github.push_ssh_key
    end

    def self.get_email
      puts 'please enter an email:'
      $stdin.gets.chomp
    end

    def self.get_title
      puts 'please enter a title for your ssh key'
      $stdin.gets.chomp
    end
  end
end
