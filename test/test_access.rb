# frozen_string_literal: true

require 'test_helper'

# tests VpsCli::Access
class TestAccess < Minitest::Test
  include VpsCli

  def setup
    @logger = create_logger(__FILE__)
    @access_dir = 'test_access_dir'
    @netrc_file = File.join(@access_dir, 'netrc')

    @root_dir = File.expand_path('../', __dir__)
    @yaml_file = File.join(@root_dir, 'example_credentials.yaml')
    mk_dirs(@access_dir)
  end

  def teardown
    rm_dirs(@access_dir)
  end

  def test_writes_to_netrc_file_if_not_given_a_file_that_exists
    # checks the file is empty
    # assert File.zero? @netrc_file
    refute File.exist?(@netrc_file)
    log_methods(@logger) do
      Access.write_to_netrc(netrc_file: @netrc_file, string: 'test_string')
    end

    refute File.zero?(@netrc_file)
    assert_equal File.read(@netrc_file), 'test_string'
  end

  def test_overwrites_existing_netrc
    FileUtils.touch(@netrc_file)
    File.write(@netrc_file, 'test')
    assert_equal File.read(@netrc_file), 'test'

    log_methods(@logger) do
      Access.write_to_netrc(netrc_file: @netrc_file, string: 'testing')
    end

    refute_equal File.read(@netrc_file), 'test'
  end

  def test_adds_an_error_to_vps_cli_errors
    FileUtils.touch(@netrc_file)
    FileUtils.chmod('-w', @netrc_file)

    VpsCli.errors = []
    assert_empty VpsCli.errors

    log_methods(@logger) do
      Access.write_to_netrc(netrc_file: @netrc_file, string: 'hi')
    end

    refute_empty VpsCli.errors
  end

  def test_dig_for_path_returns_a_string
    string = Access.dig_for_path(:heroku, :api, :login)
    assert_instance_of String, string
    assert_equal string, '["heroku"]["api"]["login"]'
  end

  def test_dig_for_path_works_with_nested_arrays
    string = Access.dig_for_path([[[:heroku], :api], :login])
    assert_equal string, '["heroku"]["api"]["login"]'
  end

  def test_decrypt_works_with_master_key_in_config_file
    path = Access.dig_for_path(:heroku, :api, :login)
    actual_login_string = 'login random_username'

    test_string = ''
    log_methods(@logger) do
      test_string = Access.decrypt(yaml_file: @yaml_file, path: path)
    end

    assert_equal actual_login_string, test_string
  end

  def test_decrypt_does_not_work_with_bad_path
    path = Access.dig_for_path(:heroku, :api, :wrong_login)
    actual_login_string = 'login random_username'

    test_string = ''
    log_methods(@logger) do
      test_string = Access.decrypt(yaml_file: @yaml_file, path: path)
    end

    assert_empty test_string
    refute_equal actual_login_string, test_string
  end

  def test_my_inject_with_count
    array = %i[heroku api login]
    value = Access.my_inject_with_count(array) do |accum, element, count|
      element = element.to_s + count.to_s if count < array.size - 1
      accum + element.to_s
    end

    actual_string = 'heroku0api1login'
    assert_equal value, actual_string
  end

  def test_heroku_api_string_returns_proper_string
    machine = "machine api.heroku.com\n  "
    login = "login random_username\n  "
    password = 'password blahblahblah'

    final_string = "#{machine}#{login}#{password}"

    test_string = ''
    log_methods(@logger) do
      test_string = Access.heroku_api_string(yaml_file: @yaml_file)
    end

    assert_equal final_string, test_string
  end

  def test_heroku_git_string_returns_proper_string
    machine = "machine git.heroku.com\n  "
    login = "login random_username\n  "
    password = 'password more_random_stuff'

    final_string = "#{machine}#{login}#{password}"

    test_string = ''
    log_methods(@logger) do
      test_string = Access.heroku_git_string(yaml_file: @yaml_file)
    end

    assert_equal final_string, test_string
  end

  def test_heroku_file_login_works_properly
    api_machine = "machine api.heroku.com\n  "
    api_login = "login random_username\n  "
    api_password = 'password blahblahblah'

    git_machine = "machine git.heroku.com\n  "
    git_login = "login random_username\n  "
    git_password = 'password more_random_stuff'

    final_string = "#{api_machine}#{api_login}#{api_password}\n"
    final_string += "#{git_machine}#{git_login}#{git_password}"

    log_methods(@logger) do
      Access.heroku_file_login(netrc_file: @netrc_file, yaml_file: @yaml_file)
    end

    netrc_file_contents = File.read(@netrc_file)

    assert_equal netrc_file_contents, final_string
  end
end
