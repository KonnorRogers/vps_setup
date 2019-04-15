# frozen_string_literal: true

require 'test_helper'

# Tests VpsCli::Setup
class TestSetup < Minitest::Test
  def test_privileged_user
    # If this returns true, you are running the test suite as sudo
    refute VpsCli::Setup.privileged_user?

    Process.stub(:uid, 0) do
      assert VpsCli::Setup.privileged_user?
    end
  end

  def test_root
    Process.stub(:uid, 0) do
      Dir.stub(:home, '/root') do
        assert VpsCli::Setup.root?
      end
    end

    refute VpsCli::Setup.root?
  end
end
