# frozen_string_literal: true

require 'rake'
require 'yaml'
require 'fileutils'

module Rusky
  class Hook
    include Rake::DSL if defined? Rake::DSL

    attr_reader :hook_name, :cwd, :filename, :setting

    def initialize(hook_name, cwd, setting=nil)
      @hook_name = hook_name
      @cwd = cwd
      @filename = File.join(@cwd, '.git', 'hooks', hook_name)
      @setting = setting
    end

    def create
      if !exists?
        puts "rusky > creating #{hook_name} hook script..."
        write
      else
        if is_rusky_hook?
          puts "rusky > overwriting #{hook_name} hook script because also existing one is created by rusky."
          write
        else
          puts "rusky > skip creating #{hook_name} hook script because existing one is created by you or other tool."
        end
      end
      self
    end

    def delete
      if !exists?
        puts "rusky > skip deleting #{hook_name} hook script since there is no git hook file."
      else
        if is_rusky_hook?
          puts "rusky > removing #{hook_name} hook script..."
          File.delete(filename)
        else
          puts "rusky > skip deleting #{hook_name} hook script because existing one is created by you or other tool."
        end
      end
      self
    end

    def define_task
      # prioritize existing user hook
      if Rake::Task.task_defined? rake_task_name
        puts "rusky > skip creating a new rake task since the task for #{hook_name} is already defined."
        return
      end

      commands = setting&.commands_for hook_name

      task "#{rake_task_name}" do
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

    private

    def rake_task_name
      @rake_task_name ||= "rusky:#{hook_name.gsub('-', '_')}"
    end

    def exists?
      @exists ||= File.exists?(filename)
    end

    def is_rusky_hook?
      @is_rusky_hook ||= exists? && File.read(filename).include?('rusky')
    end

    def write
      File.write filename, hook_script
      FileUtils.chmod(0755, filename)
    end

    def no_verify_message
      can_bypass? ? '(add --no-verify to bypass)' : '(cannot be bypassed with --no-verify due to Git specs)'
    end

    def can_bypass?
      hook_name != 'prepare-commit-msg'
    end

    def hook_script
      <<~EOS
        #!/bin/sh
        #rusky #{Rusky::VERSION}
        has_hook_script () {
          [ -f .rusky ] && cat .rusky | grep -q "$1:"
        }
        cd "#{cwd}"
        # Check if #{hook_name} script is defined, skip if not
        has_hook_script #{hook_name} || exit 0

        # Export Git hook params
        export GIT_PARAMS="$*"
        # Run command
        echo "rusky > #{hook_name} Git hook is running"
        echo "rusky > bundle exec rake #{rake_task_name}"
        echo
        bundle exec rake #{rake_task_name} || {
          echo
          echo "rusky > #{hook_name} Git hook failed #{no_verify_message}"
          exit 1
        }
      EOS
    end
  end
end

