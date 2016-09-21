require "rails_helper"

RSpec.describe RummagerNotifier do
  describe '#notify' do
    it 'indexes the license finder page' do
      expect(SearchIndexer).to receive(:call)

      described_class.notify
    end
  end
end
