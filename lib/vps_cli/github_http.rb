# frozen_string_literal: true

require 'json'
require 'net/http'

module VpsCli
  # An http wrapper for github api request
  class GithubHTTP
    attr_accessor :uri, :title
    attr_writer :token, :ssh_file

    # @param uri [URI] the url to hit
    # @param token [String] Github API token to use
    # @param ssh_key [String] Your ssh file IE: ~/.ssh/id_rsa.pub
    # @param title [String] The title of your ssh key
    #   Ensure it is in the format: "token 14942842859"
    def initialize(uri:, token:, ssh_file:, title:)
      @uri = uri
      @token = token
      @ssh_file = ssh_file
      @ssh_key = File.read(ssh_file)
      @headers = headers(token: token)
      @title = title
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

    # Returns the appropriate json string to write an ssh key
    # @return [String] Returns a json formatted string to write an ssh key
    def ssh_json_string
      { 'title' => @title,
        'key' => @ssh_key }.to_json
    end

    # base method for an http connection
    # @yieldparam http [Net::HTTP] yields the http class
    # @return Whatever the value of yield is
    def start_connection
      Net::HTTP.start(@uri.host, @uri.port, use_ssl: true) do |http|
        yield(http)
      end
    end

    # Pushes your public key to github
    # to push your ssh key to the github
    # @return Net::HTTPResponse
    def push_ssh_key
      get = get_request

      post = post_request(data: ssh_json_string)

      response = start_connection do |http|
        get_response = http.request(get)

        ssh_keys_json = get_response.body
        return ssh_key_found_msg if ssh_key_exist?(json_string: ssh_keys_json)

        http.request(post)
      end

      VpsCli.errors << response if response != Net::HTTPSuccess

      puts response
      response
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

    # Checks if the ssh key is already found
    def ssh_key_exist?(json_string:)
      # just in case your ssh key has a comment in it
      # keys pulled from github will not have comments
      ssh_key = @ssh_key.split('==')[0].concat('==')

      p json_string
      JSON.parse(json_string).any? do |data|
        p data['key']
        data['key'] == ssh_key
      end
    end

    def ssh_key_found_msg
      puts 'The ssh key provided is already on github, no post request made.'
    end
  end
end
