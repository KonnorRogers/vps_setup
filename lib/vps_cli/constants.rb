module VpsCli
  class FileConstants
    # @!group Top Level Constants

    # Project's Root Directory
    ROOT = File.expand_path(File.expand_path('../', __dir__))

    # Projects config_files directory
    FILES_DIR = File.join(ROOT, 'config_files')

    # Projects Dotfiles directory
    DOTFILES_DIR = File.join(FILES_DIR, 'dotfiles')

    # Miscellaneous files like sshd_config
    MISC_FILES_DIR = File.join(FILES_DIR, 'misc_files')

    # Directory of backup files
    BACKUP_FILES_DIR = File.join(Dir.home, 'backup_files')

    # @!endgroup
  end

  class DecryptionConstants
    HEROKU_HASH = {
      heroku: {
        api: :api,
        api_login: :api_login,
        api_password: :api_password,
        git: :git,
        git_login: :git_login,
        git_password: :git_password
      }
    }

    GITHUB_HASH = {
      github: {
        username: :username,
        email: :email,
        password: :password,
        api_token: :api_token
      }
    }
  end
end
