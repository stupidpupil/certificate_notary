require_relative 'spec_helper'

describe CertificateNotary::PerspectivesAPI::PackedBuilder do

  before(:all) do
    CertificateNotary::Timespan.dataset.delete 
    CertificateNotary::Certificate.dataset.delete 
    CertificateNotary::Service.dataset.delete 
  end

  after(:all) do
    CertificateNotary::Timespan.dataset.delete 
    CertificateNotary::Certificate.dataset.delete 
    CertificateNotary::Service.dataset.delete 
  end

  describe '.packed_data_for_service' do
    context 'with a particular service, certificate and timespans' do
      let!(:s) {CertificateNotary::Service.create(host:'example.com',port:'443',service_type:'2')}
      let!(:c) {CertificateNotary::Certificate.with_der_encoded_cert('')}
      let!(:t1){CertificateNotary::Timespan.create(service:s, certificate:c, start:Time.at(0), end:Time.at(100))}
      let!(:t2){CertificateNotary::Timespan.create(service:s, certificate:c, start:Time.at(200), end:Time.at(300))}

      it 'returns the correct data' do
        correct_data = Base64.strict_decode64('ZXhhbXBsZS5jb206NDQzLDIAAAIAEAPUHYzZjwCyBOmACZjs+EJ+AAAAAAAAAGQAAADIAAABLAACABAD1B2M2Y8AsgTpgAmY7PhCfgAAAAAAAABkAAAAyAAAASw=')
        expect(CertificateNotary::PerspectivesAPI::PackedBuilder.packed_data_for_service(s)).to eql correct_data
      end

    end
  end

end