# frozen_string_literal: true

require 'test_helper'

# This is quite difficult to test, so we will only test failures
# Due to it using the operating systems native shell
class TestInstall < Minitest::Test
  def linux
    OS.stub(:linux?, true) { yield }
  end

  def non_linux
    OS.stub(:linux?, false) { yield }
  end

  def test_full_returns_if_not_linux
    capture_io do
      # ensures its not detecting a linux env
      non_linux { assert_equal(VpsSetup::Install.full, :not_installed) }
    end
  end

  def test_full_raises_error_when_prep_errors
    raises_exception = proc { raise RuntimeError }
    capture_io do
      VpsSetup::Install.stub(:all_install, raises_exception) do
        assert_raises(RuntimeError) { VpsSetup::Install.full }
      end
    end
  end

  def test_returns_installed_with_no_errors
    VpsSetup::Install.stub(:all_install, true) do
      linux { assert_equal(VpsSetup::Install.full, :installed) }
    end
  end
end
