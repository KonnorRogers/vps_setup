# frozen_string_literal: true

require 'test_helper'

class TestPackages < Minitest::Test
  def test_each_constant_exists
    packages = [
      VpsSetup::Packages::LIBS,
      VpsSetup::Packages::LANGUAGES,
      VpsSetup::Packages::TOOLS,
      VpsSetup::Packages::ADDED_REPOS
    ]

    packages.each { |pkg_ary| refute_empty(pkg_ary) }

    refute_empty(VpsSetup::Packages::GEMS)

    packages_size = proc { |ary| ary.inject(0) { |sum, pkg| sum + pkg.size } }

    assert_equal(VpsSetup::Packages::UBUNTU.size, packages_size.call(packages))
  end
end
