require 'rusky/hook'
require 'rusky/hooks'
require 'rusky/setting'
require 'rusky/version'
require 'yaml'
require 'fileutils'

module Rusky
  def self.install
    cwd = current_work_directory_name

    unless processable?(cwd)
      puts "rusky > can't find .git directory, so skipping rusky process"
      return
    end

    Rusky::Hooks.new(cwd).create
    Rusky::Setting.new(cwd).create

    puts "rusky > installation is done. enjoy!"
  rescue => e
    puts "rusky > unexpected error happened: #{e.inspect}"
  end

  def self.uninstall
    cwd = current_work_directory_name

    unless processable?(cwd)
      puts "rusky > can't find .git directory, so skipping rusky process"
      return
    end

    Rusky::Hooks.new(cwd).delete
    Rusky::Setting.new(cwd).delete

    puts "rusky > uninstallation is done. please remove rake tasks for rusky if you have them"
    puts "rusky > Thank you for using rusky!"
  rescue => e
    puts "rusky > unexpected error happened: #{e.inspect}"
  end

  def self.current_work_directory_name
    Dir.pwd
  end

  def self.processable?(cwd)
    File.exist? File.join(cwd, '.git')
  end
end
