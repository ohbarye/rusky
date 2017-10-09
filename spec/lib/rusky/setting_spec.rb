require "spec_helper"
require "rusky/setting"

RSpec.describe Rusky::Setting do
  let(:cwd) { '/Users/butcher/repo' }
  let(:setting) { Rusky::Setting.new(cwd) }

  before do
    allow(YAML).to receive(:load_file).with('/Users/butcher/repo/.rusky').and_return({
      'pre-commit' => [
        'bundle exec rspec',
        'rubocop'
      ]
    })
  end

  describe '#create' do
    before do
      allow(File).to receive(:write).with('/Users/butcher/repo/.rusky', '')
    end

    subject { setting.create }

    it 'creates a setting file' do
      subject
      expect(File).to have_received(:write)
    end

    it 'returns itself' do
      expect(subject).to eq setting
    end
  end

  describe '#delete' do
    before do
      allow(File).to receive(:delete).with('/Users/butcher/repo/.rusky')
    end

    subject { setting.delete }

    it 'deletes a setting file' do
      subject
      expect(File).to have_received(:delete)
    end

    it 'returns itself' do
      expect(subject).to eq setting
    end
  end

  describe '#commands_for' do
    before do
      allow(File).to receive(:exists?).with('/Users/butcher/repo/.rusky').and_return true
    end

    context 'when commands are defined in the setting file' do
      subject { setting.commands_for('pre-commit') }

      it 'returns an array of commands' do
        expect(subject).to eq ['bundle exec rspec', 'rubocop']
      end
    end

    context 'when commands are not defined in the setting file' do
      subject { setting.commands_for('post-commit') }

      it 'returns an array of commands' do
        expect(subject).to be_nil
      end
    end
  end
end
