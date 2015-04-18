require 'socket'
require 'openssl'

module PerspectivesNotary
  class OpenSSLScanner

    def self.fingerprint(host, port)
      tcp_client = TCPSocket.new host, port
      ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
      ssl_client.hostname = host if Config.sni
      ssl_client.connect

      cert = ssl_client.peer_cert

      return OpenSSL::Digest::MD5.new(cert.to_der).to_s.scan(/../).join(":")

    ensure
      ssl_client.close if ssl_client
      tcp_client.close if tcp_client
    end

  end
end