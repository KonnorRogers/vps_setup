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
end
