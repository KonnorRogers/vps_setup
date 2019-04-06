# frozen_string_literal: true

# @see https://ruby-doc.org/stdlib-2.6.0.preview2/libdoc/open3/rdoc/Open3.html
require 'open3'
require 'json'
require 'net/http'

# Helper methods to be used within Access to help reduce the file size
module AccessHelper
  # retrieves the values of .netrc for heroku and creates a writable string
  # @return [String] Returns the string to be written to netrc
  def heroku_api_string(yaml_file:)
    # initial tree traversal in the .yaml file
    heroku_api = %i[heroku api]
    heroku_api_keys = %i[machine login password]

    make_string(base: heroku_api, keys: heroku_api_keys) do |path|
      decrypt(yaml_file: yaml_file, path: path)
    end
  end

  # retries the git values for heroku in your .yaml file
  # @return [String] Returns the string to be written to your netrc file
  def heroku_git_string(yaml_file:)
    heroku_git = %i[heroku git]
    heroku_git_keys = %i[machine login password]

    make_string(base: heroku_git, keys: heroku_git_keys) do |path|
      decrypt(yaml_file: yaml_file, path: path)
    end
  end

  # my version of Enumerable#inject intended to return a string
  # provides a count to know what # object youre on
  # @param array [Array<#to_s>]
  #   For each element in the array, yield to the block given.
  # @yieldparam accum [String]
  #   The value that will persist throughout the block
  # @yieldparam element [String] The current element in the array
  # @yield param count [Integer]
  # @return [String] Returns the string returned by the block passed to it
  def my_inject_with_count(array)
    value = nil
    count = 0
    array.inject('') do |accum, element|
      value = yield(accum, element, count)
      count += 1
      value # if not here, returns the value of count
    end
  end

  # Creates a string to be used to write to .netrc
  # @param base [String] Provides the base string from which to add to
  # @param keys [Array<String>] An array of strings to append to base
  # @return [String] Returns the string after concatenating them
  def make_string(base:, keys:)
    # iterates through the keys to provide a path to each array
    # essentialy is the equivalent of Hash.dig(:heroku, :api, :key)
    my_inject_with_count(keys) do |string, key, count|
      path = dig_for_path(base, key)

      value = yield(path)
      value << "\n  " if count < keys.length - 1
      string + value
    end
  end

  # Writes the value of string to netrc
  # @param netrc_file [File] ($HOME/.netrc)
  #   The location of your .netrc file to be read by heroku
  # @param string [String] The String to write to the netrc file
  # @return void
  def write_to_netrc(netrc_file: nil, string:)
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
  def netrc_error(netrc_file:, error:)
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
  def decrypt(yaml_file:, path:)
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
  def dig_for_path(*path)
    path.flatten.inject('') do |final_path, node|
      final_path + "[#{node.to_s.to_json}]"
    end
  end

  # I noticed needing to export $(tty) while troubleshooting
  # issues with gpg keys. It is here just in case its not in
  # your zshrc / bashrc file
  # @return void
  def export_tty
    Rake.sh('GPG_TTY=$(tty) && export GPG_TTY')
  end

  # Pushes your public key to github

  def github_write_key_request(token:, json_string:)
    uri = URI('https://api.github.com/user/keys')

    # puts the authorization token into the header for authorization
    request = Net::HTTP::Post.new(uri, github_headers(token: token))

    request.body = json_string

    response = nil
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      response = http.request(request)
    end

    VpsCli.errors << response if response != Net::HTTPSuccess
  end

  # The headers need for authorization of a post request
  # @param token [String] (nil) Your github API token
  #   @see https://github.com/settings/keys
  #   make sure your token has write:public_key access
  # @return [Hash] Returns the hash of headers to be put in an POST request
  def github_headers(token: nil)
    token = "token #{token}" if token
    json = 'application/json'

    { 'Content-Type' => json,
      'Accepts' => json,
      'Authorization' => token }
  end

  # Returns the appropriate json string to write an ssh key
  # @param title [String] The name you want your ssh key to have
  # @param key_content [String] The value of your ssh public key for github
  # @return [String] Returns a json formatted string to write an ssh key
  def github_ssh_key_json_string(title:, key_content:)
    ssh_key_scope = '["admin:public_key", "write:public_key"]'
    { 'scopes' => ssh_key_scope,
      'title' => title,
      'key' => key_content }
  end
end
