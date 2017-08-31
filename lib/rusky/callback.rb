module Rusky
  module Callback
    def self.install
      puts 'installed'
      rusky_dir = File.expand_path(File.dirname($0))
      puts 'File.expand_path'
      puts rusky_dir
      cwd = `lsof -p #{Process.ppid} | grep cwd`.split(" ").last
      puts cwd
    end

    def self.uninstall
      puts 'uninstalled'
      rusky_dir = File.expand_path(File.dirname($0))
      puts 'File.expand_path'
      puts rusky_dir
      cwd = `lsof -p #{Process.ppid} | grep cwd`.split(" ").last
      puts cwd
    end
  end
end
