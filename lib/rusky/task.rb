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
      @cwd = base || Rusky.current_work_directory_name
    end

    def install
      setting = Rusky::Setting.new(cwd)
      Rusky::Hooks.new(cwd, setting).define_tasks
    end
  end
end

