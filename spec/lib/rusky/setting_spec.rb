require "spec_helper"
require "rusky/setting"

RSpec.describe Rusky::Setting do
  let(:cwd) { '/Users/butcher/repo' }
  let(:filename) { "#{cwd}/.rusky" }
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
      allow(File).to receive(:write).with(filename, '')
    end

    subject { setting.create }

    it 'returns itself' do
      expect(subject).to eq setting
    end

    context 'when the setting hook file does not exist' do
      before do
        allow(File).to receive(:exist?).with(filename).and_return(false)
      end

      it 'creates the setting file' do
        subject
        expect(File).to have_received(:write)
      end
    end

    context 'when the .rusky hook file exists' do
      before do
        allow(File).to receive(:exist?).with(filename).and_return(true)
      end

      it 'does not touch the setting file' do
        subject
        expect(File).not_to have_received(:write)
      end
    end
  end

  describe '#delete' do
    before do
      allow(File).to receive(:delete).with(filename)
    end

    subject { setting.delete }

    it 'returns itself' do
      expect(subject).to eq setting
    end

    context 'when the setting hook file does not exist' do
      before do
        allow(File).to receive(:exist?).with(filename).and_return(false)
      end

      it 'does not delete the setting file' do
        subject
        expect(File).not_to have_received(:delete)
      end
    end

    context 'when the .rusky hook file exists' do
      before do
        allow(File).to receive(:exist?).with(filename).and_return(true)
      end

      it 'deletes the setting file' do
        subject
        expect(File).to have_received(:delete)
      end
    end
  end

  describe '#commands_for' do
    before do
      allow(File).to receive(:exist?).with(filename).and_return true
    end

    context 'when commands are defined in the setting file' do
      subject { setting.commands_for('pre-commit') }

      it 'returns an array of commands' do
        expect(subject).to eq ['bundle exec rspec', 'rubocop']
      end
    end

    context 'when commands are not defined in the setting file' do
      subject { setting.commands_for('post-commit') }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end
end
