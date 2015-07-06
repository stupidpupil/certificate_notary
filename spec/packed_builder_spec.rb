# This file is part of the Ruby Certificate Notary.
# 
# The Ruby Certificate Notary is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# The Ruby Certificate Notary is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with the Ruby Certificate Notary.  If not, see <http://www.gnu.org/licenses/>.

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