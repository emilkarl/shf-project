# frozen_string_literal: true

require 'rails_helper'

describe Dinkurs::CompanyEvents,
         vcr: { cassette_name: 'dinkurs/company_events',
                allow_playback_repeats: true } do

  let(:dinkurs_co_id) { ENV['DINKURS_COMPANY_TEST_ID'] }
  let(:company) { build :company, id: 1, dinkurs_company_id: dinkurs_co_id }

  let(:parsed_company_event_hash) { { 'events' => { 'event' => {}, 'company': 'ok' } } }

  around(:each) do |example|
    travel_to(Time.utc(2018, 6, 1)) do
      example.run
    end
  end

  describe '.create_from_dinkurs' do

    # Here is the data from the vcr info:
    #
    # data after it has been parsed:
    # {:dinkurs_id=>"30902", :name=>"Grundarrangemang-utskick", :location=>"Malmö2", :fee=>0.0, :start_date=>Thu, 31 Dec 2015, :description=>"\"Hej! Geriatriska nutritionsdagarna 2016 är fulltecknade. Vi hoppas på att få se dig vid nästa geriatrikdagar 2018. Vänliga hälsningar styrelsen SiGN\"\n", :sign_up_url=>"https://dinkurs.se/appliance/?event_key=IFsKlUdNeEdLAECq", :company_id=>1}
    # {:dinkurs_id=>"39992", :name=>"Grundarrangemang-utskick kopia", :location=>"Malmö2", :fee=>100.0, :start_date=>Thu, 31 Dec 2015, :description=>"\"Hej! Geriatriska nutritionsdagarna 2016 är fulltecknade. Vi hoppas på att få se dig vid nästa geriatrikdagar 2018. Vänliga hälsningar styrelsen SiGN\"\n", :sign_up_url=>"https://dinkurs.se/appliance/?event_key=ggbTGqGPDOEPrpjY", :company_id=>1}
    # {:dinkurs_id=>"38965", :name=>"Alexander Betts", :location=>"Mathörnan Staffanstorp", :fee=>100.0, :start_date=>Thu, 08 Jun 2017, :description=>"<br />", :sign_up_url=>"https://dinkurs.se/appliance/?event_key=QBNKOUWoHMWIRTBW", :company_id=>1}
    # {:dinkurs_id=>"52189", :name=>"Grundkurs om eventry.", :location=>"Fågelvägen 8,", :fee=>10.0, :start_date=>Tue, 13 Feb 2018, :description=>nil, :sign_up_url=>"https://dinkurs.se/appliance/?event_key=uOEFUZvIDXrnOWFA", :company_id=>1}
    # {:dinkurs_id=>"52524", :name=>"2 The keeper of Star Wars props and costumes speaks to StarWars.com.", :location=>"Lucasfilm", :fee=>0.0, :start_date=>Thu, 21 Jun 2018, :description=>"<p>Hejsan! </p><p>DETTA ÄR ETT AUTOMATISKT MAIL.&amp;nbsp; SE BIFOGAD FIL FÖR ORGINALFAKTURA OCH PÅMINNELSE. NOTERA ATT INGEN FAKTURA SKICKAS VIA BREV.</p><p><strong>Fakturapåminnelse.Enligt våra noteringar är fakturan ni tidigare fått fortfarande ej betald. Vi ber Er att betala dessa utan ytterligare dröjsmål.Om Ni har betalat efter utskicket av denna påminnelse kan Ni bortse från denna påminnelse.Vi på Din Kurs Sverige AB har på uppdrag av arrangören att övervaka betalningen för faktura.Vid frågor om denna faktura var vänlig kontakta arrangören omgående eftersom de administrerar fakturamallen betaldagar.Vänliga HälsningarTeamet på Din Kurs</strong>&amp;nbsp;</p>", :sign_up_url=>"https://dinkurs.se/appliance/?event_key=GISHIQMffkYPKLoY", :company_id=>1}
    # {:dinkurs_id=>"47250", :name=>"The keeper of Star Wars props and costumes speaks to StarWars.com.", :location=>"Lucasfilm", :fee=>0.0, :start_date=>Thu, 21 Jun 2018, :description=>"<p>Hejsan! </p><p>DETTA ÄR ETT AUTOMATISKT MAIL.&amp;nbsp; SE BIFOGAD FIL FÖR ORGINALFAKTURA OCH PÅMINNELSE. NOTERA ATT INGEN FAKTURA SKICKAS VIA BREV.</p><p><strong>Fakturapåminnelse.Enligt våra noteringar är fakturan ni tidigare fått fortfarande ej betald. Vi ber Er att betala dessa utan ytterligare dröjsmål.Om Ni har betalat efter utskicket av denna påminnelse kan Ni bortse från denna påminnelse.Vi på Din Kurs Sverige AB har på uppdrag av arrangören att övervaka betalningen för faktura.Vid frågor om denna faktura var vänlig kontakta arrangören omgående eftersom de administrerar fakturamallen betaldagar.Vänliga HälsningarTeamet på Din Kurs</strong>&amp;nbsp;</p>", :sign_up_url=>"https://dinkurs.se/appliance/?event_key=lnackyUeEcppHYH ", :company_id=>1}
    # {:dinkurs_id=>"48712", :name=>"Deltagarhantering har aldrig varit enklare!", :location=>"Östergatan", :fee=>2368.0, :start_date=>Mon, 31 Dec 2018, :description=>"<p><strong>Office 365 är en samlingsterm för Microsoft's cloud tjänster.&amp;nbsp;</strong></p><p>&amp;nbsp;</p><p>Saas (Software as a Service) modelen ersätter den gamla standarden av köp, nedladdgning samt installation av mjukvara på varje dator på arbetsplatsen. Grundtanken är att premuneration på tjänster ger åtkomst till ditt office 24 timmar om dygnet 365 dagar om året. Så även om du loggar in på en tablet eller smart telefon på resa, en bärbar dator i sängen eller en arbetsstation på ditt kontor, kan du komma åt alla de verktyg eller information du behöver. Flera enhe</p>", :sign_up_url=>"https://dinkurs.se/appliance/?event_key=kNzMWFFQTWKBgLPM", :company_id=>1}
    #  No Location:
    # {:dinkurs_id=>"13343", :name=>"Beställningsformulär", :location=>nil, :fee=>0.0, :start_date=>Wed, 08 Jun 2022, :description=>nil, :sign_up_url=>"https://dinkurs.se/appliance/?event_key=pTPQREGNgBXGNMQn", :company_id=>1}
    # {:dinkurs_id=>"28613", :name=>"Betaling (DKK)", :location=>nil, :fee=>0.0, :start_date=>Fri, 01 Jan 2100, :description=>nil, :sign_up_url=>"https://dinkurs.se/appliance/?event_key=PEpnLgEsMLFBlGjV", :company_id=>1}
    # {:dinkurs_id=>"30016", :name=>"Betalning (SEK)", :location=>nil, :fee=>0.0, :start_date=>Fri, 01 Jan 2100, :description=>nil, :sign_up_url=>"https://dinkurs.se/appliance/?event_key=MRCLQjAQUStcThxB", :company_id=>1}
    # {:dinkurs_id=>"26296", :name=>"Nyhetsbrevslista", :location=>nil, :fee=>0.0, :start_date=>Fri, 01 Jan 2100, :description=>nil, :sign_up_url=>"https://dinkurs.se/appliance/?event_key=qPZFJwFENEqVwcvI", :company_id=>1}

    it 'creates events' do
      expect(Event).to receive(:create).exactly(3).times
      described_class.create_from_dinkurs(company)
    end

    it 'calls Dinkurs::RestRequest to get the events info for a company' do
      allow(Dinkurs::EventsParser).to receive(:parse)

      expect(Dinkurs::RestRequest).to receive(:company_events_hash).and_return(parsed_company_event_hash)
      described_class.create_from_dinkurs(company)
    end

    it 'calls the Dinkurs::EventsParser to fetch the events data for a company' do
      allow(Dinkurs::RestRequest).to receive(:company_events_hash).and_return(parsed_company_event_hash)

      expect(Dinkurs::EventsParser).to receive(:parse).with(anything, company.id)
      described_class.create_from_dinkurs(company)
    end

    it 'default date is 1 day ago' do
      expect(described_class.create_from_dinkurs(company)).to eq(described_class.create_from_dinkurs(company, Date.current - 1.day))
    end

    it 'does not create an Event if event location is blank' do
      allow(described_class).to receive(:dinkurs_events_hashes).and_return([start_date: Time.utc(2018, 6, 1)])
      expect(Event).not_to receive(:create)
      described_class.create_from_dinkurs(company)
    end

    context 'event location is not blank' do

      it 'does not create an Event if start date < the given date' do
        given_start_date = Time.utc(2018, 5, 31)

        allow(described_class).to receive(:dinkurs_events_hashes).and_return([{ location: 'some location',
                                                                                start_date: (given_start_date - 1.day) }])
        expect(Event).not_to receive(:create)
        described_class.create_from_dinkurs(company, given_start_date)
      end

      it 'creates an Event if the event start date >= the given date' do
        given_start_date = Time.utc(2018, 5, 31)
        allow(described_class).to receive(:dinkurs_events_hashes).and_return([{ location: 'some location',
                                                                                start_date: given_start_date },
                                                                              { location: 'some location',
                                                                                start_date: given_start_date + 1.day }
                                                                             ])
        expect(Event).to receive(:create).twice
        described_class.create_from_dinkurs(company, given_start_date)
      end
    end

    context 'when date given' do
      let(:given_time) { '2017-07-06 00:00:00'.to_time }
      subject(:event_creator) do
        described_class.create_from_dinkurs(company, given_time)
      end

      context 'event location is not blank' do
        it 'creates events only if last_modified_in_dinkurs date after given date' do
          expect(Event).to receive(:create).exactly(4).times
          described_class.create_from_dinkurs(company, given_time)
        end

        it 'creates an event if last_modified_in_dinkurs date is equal to the given date' do
          expect(Event).to receive(:create).exactly(3).times
          june_21 =  Time.utc(2018, 6, 21)
          described_class.create_from_dinkurs(company, june_21)
        end
      end
    end

    context 'bad event format received from Dinkurs' do
      it 'includes company id and company dinkurs id in error message' do
        allow(Dinkurs::RestRequest).to receive(:company_events_hash).and_return('some string')
        expect { described_class.create_from_dinkurs(company) }.to raise_error(Dinkurs::Errors::InvalidFormat, /company\.id: 1 dinkurs_company_id: #{dinkurs_co_id}/)
      end

      it 'raises InvalidFormat error and displays the source information' do
        # This happened on 11 August 2020:
        #   Failure! Failure! undefined method `dig' for #<String:0x0000000008be2140> 2020-08-12 02:01:41 UTC
        #   SHF: DinkursFetch | Aug 11th

        allow(Dinkurs::RestRequest).to receive(:company_events_hash).and_return('some string')
        expect { described_class.create_from_dinkurs(company) }.to raise_error(Dinkurs::Errors::InvalidFormat, /Could not get event info from: "some string"/)
      end

      it 'company info added to msg of any error raised by anything during the call and continues up (is not stopped or changed)' do
        allow(Dinkurs::RestRequest).to receive(:company_events_hash).and_raise(Dinkurs::Errors::InvalidFormat, 'bad error message')
        expect { described_class.create_from_dinkurs(company) }.to raise_error(Dinkurs::Errors::InvalidFormat, /company\.id: 1 dinkurs_company_id: #{dinkurs_co_id} bad error message/)
      end
    end
  end
end

