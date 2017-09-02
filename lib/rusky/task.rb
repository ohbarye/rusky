require 'rake'
require 'yaml'
require 'rusky'

module Rusky
  class Task
    include Rake::DSL if defined? Rake::DSL

    class << self
      def install_tasks(base=nil)
        new(base).install
      end
    end

    def initialize(base=nil)
      @base = base || `lsof -p #{Process.ppid} | grep cwd`.split(" ").last
      @yaml = YAML.load_file(File.join(@base, '.rusky'))
    end

    def install
      Rusky::HOOKS.each do |hook_name|
        rake_task_name = "rusky:#{hook_name.gsub('-', '_')}"

        # prioritize existing user hook
        if Rake::Task.task_defined? rake_task_name
          next # Need to invoke?
        end

        task "#{rake_task_name}" do
          commands = @yaml[hook_name]

          commands.each do |command|
            puts "rusky > #{command}"
            system(command) || raise("#{command} failed")
          end
        end
      end
    end
  end
end

Rusky::Task.install_tasks
