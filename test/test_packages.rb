# frozen_string_literal: true

require 'test_helper'

class TestPackages < Minitest::Test
  def test_each_constant_exists
    packages = [
      VpsCli::Packages::LANGUAGES,
      VpsCli::Packages::TOOLS,
      VpsCli::Packages::ADDED_REPOS,
      VpsCli::Packages::GEMS
    ]

    packages.each { |pkg_ary| refute_empty(pkg_ary) }

    packages_size = proc { |ary| ary.inject(0) { |sum, pkg| sum + pkg.size } }
    size = packages_size.call(packages) - packages[3].size
    assert_equal(VpsCli::Packages::UBUNTU.size, size)
  end
end
