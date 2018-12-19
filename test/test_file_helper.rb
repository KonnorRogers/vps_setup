require 'minitest/autorun'
require 'fileutils'


class TestFileHelper < Minitest::Test
  def setup
    @fh = FileHelper.new
    Dir.mkdir('test_dir')
    @test_dir = 'test_dir'
    @file1 = File.new(File.join(@test_dir, 'test_file_1'), 'w+')
    @file2 = File.new(File.join(@test_dir, 'test_file_2'), 'w+')
  end

  def teardown
    FileUtils.rm_rf(@test_dir)
  end

  def test_file_is_copied
    test_file = 'copied_test_file'

    assert_equal File.exist?(test_file), false
    @fh.copy_file(@file1, test_file, @test_dir)
    assert File.exist?(File.join(@test_dir, test_file))

  end
end
