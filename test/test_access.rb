# frozen_string_literal: true

require 'test_helper'

class TestAccess < Minitest::Test
  @@access_dir = 'test_access_dir'
  @@netrc_file = File.join(@@access_dir, 'netrc')

  def setup
    mk_dirs(@@access_dir)
  end

  def teardown
    rm_dirs(@@access_dir)
  end

  def test_writes_to_netrc_file_if_not_given_a_file_that_exists
    # checks the file is empty
    # assert File.zero? @@netrc_file
    refute File.exist?(@@netrc_file)
    VpsCli::Access.write_to_netrc(netrc_file: @@netrc_file, string: 'test_string')

    refute File.zero?(@@netrc_file)
    assert_equal File.read(@@netrc_file), 'test_string'
  end

  def test_overwrites_existing_netrc
    FileUtils.touch(@@netrc_file)
    File.write(@@netrc_file, 'test')
    assert_equal File.read(@@netrc_file), 'test'

    VpsCli::Access.write_to_netrc(netrc_file: @@netrc_file, string: 'test_string')

    refute_equal File.read(@@netrc_file), 'test'
  end
end
