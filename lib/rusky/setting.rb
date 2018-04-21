# frozen_string_literal: true

require 'yaml'

module Rusky
  class Setting
    attr_reader :cwd, :filename

    FILENAME = '.rusky'

    def initialize(cwd)
      @cwd = cwd
      @filename = File.join(@cwd, FILENAME)
      @yaml = exists? ? YAML.load_file(filename) : Hash.new([])
    end

    def create
      if !exists?
        puts "rusky > creating .rusky file..."
        File.write(filename, '')
      end
      self
    end

    def delete
      if exists?
        puts "rusky > deleting .rusky file..."
        File.delete(filename)
      end
      self
    end

    def commands_for(hook_name)
      @yaml[hook_name]
    end

    private

    def exists?
      @exists ||= File.exists? filename
    end
  end
end

