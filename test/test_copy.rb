# frozen_string_literal: true

require 'test_helper'
require 'stringio'
require 'logger'

LOG_PATH = File.join(LOGS_DIR, "#{File.basename(__FILE__, '.rb')}.log")
LOG_FILE = File.new(LOG_PATH, 'w+')
LOGGER = Logger.new(LOG_FILE)

class TestCopy < Minitest::Test
  include VpsSetup

  def setup
    LOGGER.info("#{class_name}::#{name}")
    @console = capture_console
    rm_dirs(BACKUP_DIR, DEST_DIR)
  end

  def teardown
    LOGGER.info(@console[:fake_out].string)
    LOGGER.error(@console[:fake_err].string)

    restore_out_err(@console)
    rm_dirs(BACKUP_DIR, DEST_DIR)
  end

  # HELPER METHODS #
  def dir_children(dir)
    # Reads as \A == beginning of string
    # \. == '.' {1,2} means minimum 1, maximum 2 occurences
    # \Z == end of string
    Dir.foreach(dir).reject { |file| file =~ /\A\.{1,2}\Z/ }
  end

  def linux_env
    OS.stub(:posix?, true) do
      OS.stub(:linux?, true) do
        OS.stub(:cygwin?, false) do
          yield
        end
      end
    end
  end

  def process_uid_eql_zero
    # mimics being a super user
    Process.stub(:uid, 0) do
      yield
    end
  end

  def cygwin_env
    OS.stub(:posix?, true) do
      OS.stub(:linux?, false) do
        OS.stub(:cygwin?, true) do
          yield
        end
      end
    end
  end

  def non_posix_env
    OS.stub(:posix?, false) { yield }
  end

  def copy(backup_dir: BACKUP_DIR, dest_dir: DEST_DIR, ssh_dir: nil)
    Copy.stub(:copy_sshd_config, true) do
      Copy.copy(backup_dir: backup_dir, dest_dir: dest_dir, ssh_dir: ssh_dir)
    end
  end

  # END OF HELPER METHODS #

  def test_creates_backup_dir_and_dest_dir
    refute(Dir.exist?(BACKUP_DIR))
    refute(Dir.exist?(DEST_DIR))

    linux_env do
      copy
    end

    assert(Dir.exist?(BACKUP_DIR))
    assert(Dir.exist?(DEST_DIR))
  end

  def test_will_not_error_if_backup_dir_and_dest_dir_exist
    FileUtils.mkdir_p(BACKUP_DIR)
    FileUtils.mkdir_p(DEST_DIR)
    assert(Dir.exist?(BACKUP_DIR))
    assert(Dir.exist?(DEST_DIR))

    linux_env do
      copy
    end

    assert(Dir.exist?(BACKUP_DIR))
    assert(Dir.exist?(DEST_DIR))
  end

  def test_backup_dir_empty_and_dest_dir_should_not_be_empty
    # # Will not add files to the backup_dir if original dotfiles do not exist
    # assert_equal dir_children(BACKUP_DIR).size, 1
    # dconf automatically adds a file here, cannot stop this behavior without stubbing
    linux_env do
      VpsSetup::Copy.stub(:copy_gnome_settings, true) do
        copy
      end
    end

    assert_empty(dir_children(BACKUP_DIR))

    refute_empty(dir_children(DEST_DIR))
    assert_includes(dir_children(DEST_DIR), '.vimrc')
  end

  def test_backup_dir_not_empty_if_orig_found
    FileUtils.mkdir_p(DEST_DIR)
    backup_file = File.join(BACKUP_DIR, 'vimrc.orig')
    dest_file = File.join(DEST_DIR, '.vimrc')

    File.open(dest_file, 'w+') { |file| file.puts 'test' }
    dest_file_before_copy = File.read(dest_file)

    linux_env do
      copy
    end

    refute_empty(dir_children(BACKUP_DIR))
    assert_includes(dir_children(BACKUP_DIR), 'vimrc.orig')

    assert dest_file_before_copy == File.read(backup_file)
    refute dest_file_before_copy == File.read(dest_file)
  end

  def test_backup_file_will_not_be_overwritten
    FileUtils.mkdir_p(DEST_DIR)
    FileUtils.mkdir_p(BACKUP_DIR)
    f1 = File.join(DEST_DIR, '.vimrc')
    f2 = File.join(BACKUP_DIR, '.vimrc.orig')
    File.open(f1, 'w+') { |file| file.puts '1' }
    File.open(f2, 'w+') { |file| file.puts '2' }
    linux_env do
      copy
    end
    refute File.read(f1) == File.read(f2)
  end

  def test_config_file_will_be_copied_to_dest_dir
    config_file = File.join(CONFIG_DIR, 'vimrc')
    dest_file = File.join(DEST_DIR, '.vimrc')

    assert_raises(Errno::ENOENT) { File.read(config_file) == File.read(dest_file) }

    FileUtils.mkdir_p(DEST_DIR)
    File.open(dest_file, 'w+') { |file| file.puts 'test' }
    refute File.read(config_file) == File.read(dest_file)

    linux_env do
      copy
    end

    assert File.read(config_file) == File.read(dest_file)
  end

  def test_cygwin_files_not_copied_in_unix
    linux_env do
      copy
    end

    refute File.exist?(File.join(DEST_DIR, '.minttyrc'))
    refute File.exist?(File.join(DEST_DIR, '.cygwin_zshrc'))
  end

  def test_unix_files_not_copied_in_cygwin
    cygwin_env do
      copy
    end

    unix_zshrc = File.join(CONFIG_DIR, 'zshrc')
    cygwin_zshrc = File.join(CONFIG_DIR, 'cygwin_zshrc')
    dest_zshrc = File.join(DEST_DIR, '.zshrc')

    assert File.exist?(dest_zshrc)
    refute File.read(dest_zshrc) == File.read(unix_zshrc)
    assert File.read(dest_zshrc) == File.read(cygwin_zshrc)
  end

  def test_raises_error_in_non_posix_env
    non_posix_env do
      assert_raises(RuntimeError) { copy }
    end
  end

  def test_raises_error_when_running_as_root
    process_uid_eql_zero do
      Dir.stub(:home, '/root') do # simulates root on linux
        assert_raises(RuntimeError) { copy }
      end
    end
  end
end
