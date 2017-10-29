require "spec_helper"
require "rusky/task"
require "rusky/hooks"

RSpec.describe Rusky::Setting do
  describe '.install' do
    subject { Rusky::Task.install }

    it 'creates a setting file' do
      expect_any_instance_of(Rusky::Hooks).to receive(:define_tasks)
      subject
    end
  end
end
