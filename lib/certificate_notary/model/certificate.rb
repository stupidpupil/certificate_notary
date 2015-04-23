require 'openssl'

module CertificateNotary
  class Certificate < Sequel::Model
    one_to_many :timespans
    many_to_many :services, :join_table => :timespans

    def self.with_der_encoded_cert(der_encoded_cert)
      sha256 = OpenSSL::Digest::SHA256.new(der_encoded_cert).to_s

      Certificate.find_or_create(sha256:sha256) {|c| c.der_encoded = der_encoded_cert and c.md5 = OpenSSL::Digest::MD5.new(der_encoded_cert).to_s}
    end

  end
end