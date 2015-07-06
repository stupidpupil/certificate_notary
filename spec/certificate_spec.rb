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

describe CertificateNotary::Certificate do

  after(:each) do
    CertificateNotary::Timespan.dataset.delete
    CertificateNotary::Certificate.dataset.delete
  end

  context 'creating with a DER encoded certificate' do

    cert = CertificateNotary::Certificate.with_der_encoded_cert('')

    it 'calculate and saves MD5 and SHA256 checksums' do
      expect(cert.md5).to eql 'd41d8cd98f00b204e9800998ecf8427e'
      expect(cert.sha256).to eql 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
    end

  end

end