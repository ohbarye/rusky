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
    cwd = current_work_directory_name

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
      Rusky::Hook.new(hook_name, cwd).create
    end

    rusky_setting_file_path = File.join(cwd, '.rusky')
    if !File.exists? rusky_setting_file_path
      puts "rusky > creating .rusky file"
      File.write(rusky_setting_file_path, '')
    end

    puts "rusky > install is done. enjoy!"
  rescue => e
    puts "unexpected error happened: #{e.inspect}"
  end

  def self.uninstall
    cwd = current_work_directory_name

    HOOKS.each do |hook_name|
      Rusky::Hook.new(hook_name, cwd).delete
    end

    rusky_setting_file_path = File.join(cwd, '.rusky')
    if File.exists? rusky_setting_file_path
      File.delete(rusky_setting_file_path)
      puts "rusky > removing .rusky file..."
    end

    puts "rusky > uninstall is done. please remove rake tasks for rusky if you have them"
    puts "rusky > Thank you for using rusky!"
  end

  def self.current_work_directory_name
    cwd = `lsof -p #{Process.ppid} | grep cwd`.split(" ").last
  end
end
