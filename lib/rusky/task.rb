require 'rake'
require 'yaml'
require 'rusky'

module Rusky
  class Task
    class << self
      def install(base=nil)
        new(base).install
      end
    end

    def initialize(base=nil)
      cwd = base || Rusky.current_work_directory_name
      rusky_setting_file_path = File.join(cwd, '.rusky')
      @yaml = File.exists?(rusky_setting_file_path) ? YAML.load_file(File.join(cwd, '.rusky')) : Hash.new([])
    end

    def install
      Rusky::HOOKS.each do |hook_name|
        hook = Rusky::Hook.new hook_name, base
        hook.define_task @yaml[hook_name]
      end
    end
  end
end

