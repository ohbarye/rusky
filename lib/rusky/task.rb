require 'rake'
require 'yaml'
require 'rusky'

module Rusky
  class Task
    include Rake::DSL if defined? Rake::DSL

    class << self
      def install(base=nil)
        new(base).install
      end
    end

    def initialize(base=nil)
      @base = base || `lsof -p #{Process.ppid} | grep cwd`.split(" ").last
      rusky_setting_file_path = File.join(@base, '.rusky')
      @yaml = File.exists?(rusky_setting_file_path) ? YAML.load_file(File.join(@base, '.rusky')) : Hash.new([])
    end

    def install
      Rusky::HOOKS.each do |hook_name|
        rake_task_name = "rusky:#{hook_name.gsub('-', '_')}"

        # prioritize existing user hook
        next if Rake::Task.task_defined? rake_task_name

        define_task hook_name, rake_task_name
      end
    end

    def define_task(hook_name, rake_task_name)
      task "#{rake_task_name}" do
        commands = @yaml[hook_name]

        if commands.empty?
          puts "rusky > No command for #{hook_name} is defined in .rusky file"
          next
        end

        commands.each do |command|
          puts "rusky > #{command}"
          system(command) || raise("rusky > #{command} failed")
        end
      end
    end
  end
end

