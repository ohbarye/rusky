require 'rusky/version'
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

    HOOKS.map do |hook_name|
      create_hook(hook_name, hook_path, cwd)
    end

    # TODO create .rusky file
    # TODO add `require` into Rakefile?
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
    # TODO uninstall
  end
end
