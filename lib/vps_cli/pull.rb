# frozen_string_literal: true

require 'rake'

module VpsCli
  # Pull changes from local dir into config dir
  # to be able to push changes up to the config dir
  class Pull
    extend FileHelper

    # Base pull method
    # @see VpsCli#create_options for the defaults
    # @param opts [Hash] opts various options for running the pull method
    # @option
    def all(opts = {})
      opts = VpsCli.create_options(opts)


    end

    def dotfiles(opts = {})
      opts = create_options

      Dir.each_child(opts[:dotfiles_dir]) do
|file|

      end
    end
  end
end
