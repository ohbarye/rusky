require 'rusky'
require 'thor'

module Rusky
  class CLI < Thor
    class_option :help, type: :boolean, aliases: '-h', desc: 'Show help message.'
    class_option :version, type: :boolean, aliases: '-v', desc: 'Show current version'

    desc "install", "Generate Git hooks and .rusky files"
    def install
      Rusky.install
    end

    desc "uninstall", "Remove files generated by rusky"
    def uninstall
      Rusky.uninstall
    end

    desc "version", "Show current version"
    def version
      puts Rusky::VERSION
    end
  end
end