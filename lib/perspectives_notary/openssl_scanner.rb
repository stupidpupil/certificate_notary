require 'socket'
require 'openssl'

module PerspectivesNotary
  class OpenSSLScanner

    def self.der_encoded_cert_for(host, port)
      tcp_client = TCPSocket.new host, port
      ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
      ssl_client.hostname = host if Config.sni
      ssl_client.connect

      cert = ssl_client.peer_cert

      return cert.to_der

    ensure
      ssl_client.close if ssl_client
      tcp_client.close if tcp_client
    end

  end
end