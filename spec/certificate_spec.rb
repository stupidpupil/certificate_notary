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