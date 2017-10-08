require 'yaml'

module Rusky
  class Setting
    attr_reader :cwd, :filename

    FILENAME = '.rusky'.freeze

    def initialize(cwd)
      @cwd = cwd
      @filename = File.join(@cwd, FILENAME)
      @yaml = exists? ? YAML.load_file(File.join(@filename)) : Hash.new([])
    end

    def create
      puts "rusky > creating .rusky file..."
      File.write(filename, '')
      self
    end

    def delete
      puts "rusky > deleting .rusky file..."
      File.delete(filename)
      self
    end

    def commands_for(hook_name)
      @yaml[hook_name]
    end

    def exists?
      @exists ||= File.exists? filename
    end
  end
end

