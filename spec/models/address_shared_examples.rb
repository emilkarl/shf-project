require 'rails_helper'

# FIXME stub calls to the Geocoder
# Shared examples for the  Address model


#=================================================================================
# This shared example expects that you have defined address with let:
#      let(:address)  { <some valid address with something changed> }
#
# Ex:
#     it_behaves_like 'it geocodes when validated after changing', 'street_address' do
#               let(:address) do
#                   changed_address = address_creation_method
#                   changed_address.street_address = 'new street address'
#                end
#             end
#
RSpec.shared_examples 'it geocodes when validated after changing' do | changed_description |

  it "changed  #{changed_description}" do
    expect(address).to receive(:geocode_best_possible).and_call_original.exactly(1).times
    expect(Geocoder).to receive(:search).and_call_original.at_least(1).times
    address.validate
  end

end

#=================================================================================
# This shared example expects that you have defined address with let:
#      let(:address)  { <some valid address with something changed> }
#
# Ex:
#     it_behaves_like 'it does not geocode when validated after changing', 'mail' do
#               let(:address) do
#                   changed_address = address_creation_method
#                   changed_address.mail = false
#                end
#             end
#
RSpec.shared_examples 'it does not geocode when validated after changing' do | changed_description |

  it "changed  #{changed_description}" do
    expect(address).to receive(:geocode_best_possible).never
    expect(Geocoder).to receive(:search).and_call_original.never
    address.validate
  end
end

#=================================================================================
#
RSpec.shared_examples 'needs geocoding with sql UPDATE of' do | sql_set_clause |

  let(:a_company) { create(:company, num_addresses: 0) }

  let(:norbotten_region) { create(:region, name: 'Norrbotten') }
  let(:overtornea_kommun) { create(:kommun, name: 'Övertorneå') }

  # These are real addresses in  Övertorneå Municipality in Norrbotten County:

  let(:valid_address1) do
    addr1 = create(:address,
                   street_address: 'Matarengivägen 24',
                   post_code:      '957 31',
                   city:           'Övertorneå',
                   kommun:         overtornea_kommun,
                   region:         norbotten_region,
                   addressable:    a_company,
                   mail:           false)
    addr1.validate
    addr1
  end

  let(:valid_address2) do
    addr2 = create(:address,
                   street_address: 'Skolvägen 12',
                   post_code:      '957 31',
                   city:           'Övertorneå',
                   kommun:         overtornea_kommun,
                   region:         norbotten_region,
                   addressable:    a_company)
    addr2.validate
    addr2
  end

  it "SET #{sql_set_clause}" do

    valid_address1
    valid_address2

    num_needed_geocoding = Address.not_geocoded.count
    expect(num_needed_geocoding).to eq 0

    Address.connection.execute("UPDATE addresses SET #{sql_set_clause}")
    num_needed_after_lat_null = Address.not_geocoded.count
    expect(num_needed_after_lat_null).to eq 2

    Address.geocode_all_needed
    num_needed_after_geocoding = Address.not_geocoded.count
    expect(num_needed_after_geocoding).to eq 0
  end

end


#=================================================================================

RSpec.shared_examples 'does not need geocoding with sql UPDATE of' do | sql_set_clause |

  let(:a_company) { create(:company, num_addresses: 0) }

  let(:norbotten_region) { create(:region, name: 'Norrbotten') }
  let(:overtornea_kommun) { create(:kommun, name: 'Övertorneå') }

  # These are real addresses in  Övertorneå Municipality in Norrbotten County:

  let(:valid_address1) do
    addr1 = create(:address,
                   street_address: 'Matarengivägen 24',
                   post_code:      '957 31',
                   city:           'Övertorneå',
                   kommun:         overtornea_kommun,
                   region:         norbotten_region,
                   addressable:    a_company,
                   mail:           false)
    addr1.validate
    addr1
  end

  let(:valid_address2) do
    addr2 = create(:address,
                   street_address: 'Skolvägen 12',
                   post_code:      '957 31',
                   city:           'Övertorneå',
                   kommun:         overtornea_kommun,
                   region:         norbotten_region,
                   addressable:    a_company)
    addr2.validate
    addr2
  end

  it "SET #{sql_set_clause}" do

    valid_address1
    valid_address2

    num_needed_geocoding = Address.not_geocoded.count
    expect(num_needed_geocoding).to eq 0

    Address.connection.execute("UPDATE addresses SET #{sql_set_clause}")
    num_needed_after_lat_null = Address.not_geocoded.count
    expect(num_needed_after_lat_null).to eq 0

    Address.geocode_all_needed
    num_needed_after_geocoding = Address.not_geocoded.count
    expect(num_needed_after_geocoding).to eq 0
  end

end
