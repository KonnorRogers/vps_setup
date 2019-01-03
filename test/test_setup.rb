# frozen_string_literal: true

require 'test_helper'

# Tests VpsSetup::Setup
class TestSetup < Minitest::Test
  def test_privileged_user
    # If this returns true, you are running the test suite as sudo
    refute VpsSetup::Setup.privileged_user?

    Process.stub(:uid, 0) do
      assert VpsSetup::Setup.privileged_user?
    end
  end

  def test_root
    Process.stub(:uid, 0) do
      Dir.stub(:home, '/root') do
        assert VpsSetup::Setup.root?
      end
    end

    refute VpsSetup::Setup.root?
  end

  def remove_user(user)
    ##########################
    # ONLY WORKS WITH UBUNTU #
    ##########################

    Rake.sh("sudo deluser --remove-home #{user}")
  end

  def test_add_user
    # username chosen due to not likely that it exists already'
    user = 'test_user_vps'
    capture_io do
      assert_equal VpsSetup::Setup.add_user(user), :not_privileged_user
    end

#     error = 'This will not work if you are not running as sudo / root. The Tes'
#     skip(error) unless Process.uid.zero?

#     assert_equal VpsSetup::Setup.add_user(user), :user_added
#     assert Dir.exist?("/home/#{user}")

#     assert_equal VpsSetup::Setup.add_user(user), :name_taken

#     remove_user(user)
  end

end
