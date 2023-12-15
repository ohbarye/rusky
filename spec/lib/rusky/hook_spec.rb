require "spec_helper"
require "rusky/hook"

RSpec.describe Rusky::Hook do
  let!(:cwd) { '/Users/butcher/repo' }
  let!(:hook_name) { 'pre-commit' }
  let!(:filename) { "#{cwd}/.git/hooks/#{hook_name}" }
  let!(:setting) { Rusky::Setting.new(cwd) }
  let!(:hook) { Rusky::Hook.new(hook_name, cwd, setting) }

  describe '#create' do
    subject { hook.create }

    before do
      allow(File).to receive(:write).with(filename, anything)
      allow(FileUtils).to receive(:chmod).with(0755, filename)
    end

    it 'returns itself' do
      expect(subject).to eq hook
    end

    context 'when the git hook file does not exist' do
      it 'creates the git hook file' do
        subject
        expect(File).to have_received(:write)
        expect(FileUtils).to have_received(:chmod)
      end
    end

    context 'when the git hook file exist' do
      before do
        allow(File).to receive(:exist?).with(filename).and_return(true)
      end

      context 'when the git hook file is for rusky' do
        before do
          allow(File).to receive(:read).with(filename).and_return('rusky')
        end

        it 'overwrites the git hook file' do
          subject
          expect(File).to have_received(:write)
          expect(FileUtils).to have_received(:chmod)
        end
      end

      context 'when the git hook file is not for rusky' do
        before do
          allow(File).to receive(:read).with(filename).and_return('created by another tool')
        end

        it 'does not touch the git hook file' do
          subject
          expect(File).not_to have_received(:write)
          expect(FileUtils).not_to have_received(:chmod)
        end
      end
    end
  end

  describe '#delete' do
    subject { hook.delete }

    before do
      allow(File).to receive(:delete).with(filename)
    end

    it 'returns itself' do
      expect(subject).to eq hook
    end

    context 'when the git hook file does not exist' do
      it 'does not delete the git hook file' do
        subject
        expect(File).not_to have_received(:delete)
      end
    end

    context 'when the git hook file exist' do
      before do
        allow(File).to receive(:exist?).with(filename).and_return(true)
      end

      context 'when the git hook file is for rusky' do
        before do
          allow(File).to receive(:read).with(filename).and_return('rusky')
        end

        it 'deletes the git hook file' do
          subject
          expect(File).to have_received(:delete)
        end
      end

      context 'when the git hook file is not for rusky' do
        before do
          allow(File).to receive(:read).with(filename).and_return('created by another tool')
        end

        it 'does not delete the git hook file' do
          subject
          expect(File).not_to have_received(:delete)
        end
      end
    end
  end

  describe '#define_task' do
    subject { hook.define_task }

    it 'defines rake task' do
      expect {
        subject
      }.to change {
        Rake::Task.task_defined? 'rusky:pre_commit'
      }.from(false).to(true)
    end
  end
end
