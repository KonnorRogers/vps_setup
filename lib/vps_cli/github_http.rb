# frozen_string_literal: true

require 'json'
require 'net/http'

module VpsCli
  # An http wrapper for github api request
  class GithubHTTP
    attr_accessor :uri
    attr_writer :token

    # @param uri [URI] the url to hit
    # @param token [String] Github API token to use
    #   Ensure it is in the format: "token 14942842859"
    def initialize(uri:, token:)
      @uri = uri
      @token = token
      @headers = headers(token: token)
    end

    # The headers need for authorization of a request
    # @param token [String] (nil) Your github API token
    #   @see https://github.com/settings/keys
    #   make sure your token has write:public_key and read:public_key access
    # @return [Hash] Returns a hash of headers
    def headers(token:)
      json = 'application/json'

      { 'Content-Type' => json,
        'Accepts' => json,
        'Authorization' => token }
    end

    # Pushes your public key to github
    # to push your ssh key to the github
    # @param json_string [String] The data to be sent
    # @return Net::HTTPResponse
    def write_key(json_string:)
      request = post_request(data: json_string)

      response = start_connection do |http|
        response = http.request(request)
      end

      VpsCli.errors << response if response != Net::HTTPSuccess

      response
    end

    # Returns the appropriate json string to write an ssh key
    # @param title [String] The name you want your ssh key to have
    # @param key_content [String] The value of your ssh public key for github
    # @return [String] Returns a json formatted string to write an ssh key
    def ssh_json_string(title:, key_content:)
      { 'title' => title,
        'key' => key_content }.to_json
    end

    # base method for an http connection
    # @yieldparam http [Net::HTTP] yields the http class
    # @return Whatever the value of yield is
    def start_connection
      Net::HTTP.start(@uri.host, @uri.port, use_ssl: true) do |http|
        yield(http)
      end
    end

    # @param token [String] Your github api token
    # @return [Net::HTTP::Get] Returns a new get request class
    def get_request
      Net::HTTP::Get.new(@uri, @headers)
    end

    # @param data [String] The data to send in the post request, must be json
    # @return [Net::HTTP::Post] Returns a new post request class
    def post_request(data:)
      post = Net::HTTP::Post.new(@uri, @headers)
      post.body = data
      post
    end

    # Pushes your ssh key to your github account via v3 api
    # @param yaml_file [File] File path for your credentials yaml file
    # @param title [String] Name of the ssh key title for github
    def push_ssh_key(title: nil, ssh_file: nil)
      unless title
        puts 'You did not give this ssh key a title, please enter one now'
        title = $stdin.gets.chomp
      end

      # api_token_key = dig_for_path(:github, :api_token)
      # api_token = decrypt(yaml_file: yaml_file, path: api_token_key)

      ssh_file ||= File.join(Dir.home, '.ssh', 'id_rsa.pub')
      ssh_key = File.read(ssh_file)

      # checks that the ssh key hasnt already been written
      return if ssh_key_exist?(ssh_key: ssh_key)

      json = ssh_json_string(title: title, key_content: ssh_key)

      write_key(json_string: json)
    end

    def ssh_key_exist?(ssh_key:)
      # just in case your ssh key has a comment in it
      # keys pulled from github will not have comments
      ssh_key = ssh_key.split('==')[0].concat('==')

      ssh_keys = parse_ssh_keys(all_ssh_keys)

      return true if ssh_keys.include?(ssh_key)

      false
    end

    # @return [String] Returns a json formatted string
    def all_ssh_keys
      request = get_request

      response = start_connection do |http|
        http.request(request)
      end

      VpsCli.errors << response if response != Net::HTTPSuccess

      response.body
    end

    # @param json_string [String] Json formatted string to parse
    # @return [Array<String>] Returns an array of all your ssh keys
    def parse_ssh_keys(json_string:)
      JSON.parse(json_string).map { |data| data['key'] }
    end
  end
end
