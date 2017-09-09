require 'rusky/version'
require 'rusky/cli'
require 'yaml'
require 'fileutils'

module Rusky
  HOOKS = %w[
    applypatch-msg
    pre-applypatch
    post-applypatch
    pre-commit
    prepare-commit-msg
    commit-msg
    post-commit
    pre-rebase
    post-checkout
    post-merge
    pre-push
    pre-receive
    update
    post-receive
    post-update
    push-to-checkout
    pre-auto-gc
    post-rewrite
    sendemail-validate
  ].freeze

  def self.install
    cwd = `lsof -p #{Process.ppid} | grep cwd`.split(" ").last

    git_path = File.join(cwd, '.git')
    if !File.exists? git_path
      puts "can't find .git directory, skipping Git hooks installation"
      return
    end

    hook_path = File.join(git_path, 'hooks')
    if !File.exists? hook_path
      FileUtils.mkdir_p hook_path
    end

    HOOKS.each do |hook_name|
      create_hook(hook_name, hook_path, cwd)
    end

    rusky_setting_file_path = File.join(cwd, '.rusky')
    if !File.exists? rusky_setting_file_path
      File.write(rusky_setting_file_path, '')
    end
  rescue => e
    puts "unexpected error happened: #{e.inspect}"
  end

  def self.create_hook(hook_name, hook_path, cwd)
    script = get_hook_script(hook_name, cwd)
    filename = File.join(hook_path, hook_name)

    if File.exists? filename
      if File.read(filename).include? 'rusky'
        # Overwrite
        write(filename, script)
      else
        # Keep user original Git hook
      end
    else
      write(filename, script)
    end
  end

  def self.write(filename, script)
    File.write filename, script
    FileUtils.chmod(0755, filename)
  end

  def self.get_hook_script(hook_name, cwd)
    no_verify_message = if hook_name == 'prepare-commit-msg'
                          '(cannot be bypassed with --no-verify due to Git specs)'
                        else
                          '(add --no-verify to bypass)'
                        end

    rake_task_name = "rusky:#{hook_name.gsub('-', '_')}"

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


  def self.uninstall
    cwd = `lsof -p #{Process.ppid} | grep cwd`.split(" ").last

    HOOKS.each do |hook_name|
      remove_hook(cwd, hook_name)
    end

    rusky_setting_file_path = File.join(cwd, '.rusky')
    if File.exists? rusky_setting_file_path
      File.delete(rusky_setting_file_path)
      puts "rusky > removing .rusky file..."
    end

    puts "rusky > uninstall is done. please remove rake tasks for rusky if you have them"
    puts "rusky > Thank you for using rusky!"
  end

  def self.remove_hook(cwd, hook_name)
    filename = File.join(cwd, '.git', 'hooks', hook_name)
    if File.exists?(filename) && File.read(filename).include?('rusky')
      puts "rusky > removing #{hook_name} hook script..."
      File.delete(filename)
    end
  end
end
