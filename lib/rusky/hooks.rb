require 'rusky'
require 'rusky/hook'
require 'fileutils'

module Rusky
  class Hooks
    DIR_NAME = 'hooks'

    HOOK_NAMES = %w[
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

    attr_reader :cwd, :dir_name, :hooks

    def initialize(cwd, setting=nil)
      @cwd = cwd
      @dir_name = File.join(cwd, '.git', 'hooks')
      @hooks = HOOK_NAMES.each { |hook_name| Rusky::Hook.new(hook_name, cwd, setting) }
    end

    def create
      mkdir unless exists?
      hooks.each(&:create)
    end

    def delete
      return unless exists?
      hooks.each(&:delete)
    end

    def define_tasks
      hooks.each(&:define_task)
    end

    def exists?
      @exists ||= File.exists? dir_name
    end

    def mkdir
      FileUtils.mkdir_p dir_name
    end
  end
end
