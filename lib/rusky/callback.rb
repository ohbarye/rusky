module Rusky
  module Callback
    def self.install
      puts 'installed'
      rusky_dir = File.expand_path(File.dirname($0))
      puts rusky_dir
    end

    def self.uninstall
      puts 'uninstalled'
      rusky_dir = File.expand_path(File.dirname($0))
      puts rusky_dir
    end
  end
end
