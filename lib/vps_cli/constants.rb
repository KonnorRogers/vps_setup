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
    # @param hash_name [Symbol, String] The name of the hash to be used
    #   as the top level for a yaml tree
    #   IE: if your yaml tree goes: ['heroku']['api']
    #   Then your hash_name is 'heroku'
    # @param keys [Array<Symbol>] The value of the keys in your tree
    #   IE: if your taml tree contains:
    #   ['heroku']['api'] and ['heroku']['api_login']
    #   Then your array of keys will look like this:
    #   [:api, :api_login]
    # @return [Hash<Symbol, String>] returns a hash easily decrypted
    #   by FileHelper#decrypt
    # @see VpsCli::FileHelper#decrypt
    def self.create_hash(hash_name, keys)
      hash = Hash.new do |hash, key|
        hash[key] = "[\"{hash_name}\"][\"#{hash[key]}\"]"
      end

      keys.each { |key| hash[key] }

      hash
    end

    HEROKU_KEYS = %i[
    api api_login api_password
    git git_login git_password
    ]

    GITHUB_KEYS = %i[username email password api_token]

    # @todo move this somewhere
    HEROKU_HASH = create_hash(:heroku, HEROKU_KEYS)
    GITHUB_HASH = create_hash(:github, GITHUB_KEYS)
  end
end
