require 'rails_helper'

describe ShortenUrl do

  let(:log_file) { LogfileNamer.name_for(ShortenUrl) }

  describe '.short' do
    it 'creates shortened link' do
      VCR.use_cassette('shorten_url/short') do
        shortened_url = ShortenUrl.short 'http://sverigeshundforetagare.se/anvandare/2/proof_of_membership'
        expect(shortened_url).to match 'tinyurl.com/ya6sa84h'
      end
    end
    it 'if the service raises an error, returns nil and writes to the log' do
      VCR.use_cassette('shorten_url/error') do
        expect(ActivityLogger).to receive(:open).and_call_original
        shortened_url = ShortenUrl.short '/'
        expect(shortened_url).to eq nil

        expect(File.read(log_file))
          .to include "[TINYURL_API] [shortening url] [error] Exception: HTTParty::Error\n" +
                      "[TINYURL_API] [shortening url] [error] Attempted URL: /\n" +
                      '[TINYURL_API] [shortening url] [error] Response body: ERROR'
      end
    end
  end
end
