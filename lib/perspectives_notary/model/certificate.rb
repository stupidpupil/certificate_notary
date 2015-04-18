require 'openssl'

module PerspectivesNotary
  class Certificate < Sequel::Model

    def self.with_der_encoded_cert(der_encoded_cert)
      sha256 = OpenSSL::Digest::SHA256.new(der_encoded_cert).to_s

      Certificate.find_or_create(sha256:sha256) {|c| c.der_encoded = der_encoded_cert and c.md5 = OpenSSL::Digest::MD5.new(der_encoded_cert).to_s}
    end

  end
end