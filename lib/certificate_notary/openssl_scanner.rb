require 'socket'
require 'openssl'

module CertificateNotary
  class OpenSSLScanner

    NET_EXCEPTIONS = [
      Errno::EHOSTUNREACH, 
      Errno::ENETUNREACH,
      Errno::ECONNRESET,
      Errno::ECONNABORTED,
      Errno::ECONNREFUSED,
      Errno::EINVAL,
      Errno::ETIMEDOUT
    ]

    def self.der_encoded_cert_for(host, port)
       
      begin

        tcp_client = nil
        ssl_client = nil
        cert = nil

        Timeout::timeout(5) {
          tcp_client = TCPSocket.new host, port
          ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
          ssl_client.hostname = host if Config.sni
          ssl_client.connect
          cert = ssl_client.peer_cert
        }

      rescue Timeout::Error, SocketError, OpenSSL::SSL::SSLError, *NET_EXCEPTIONS => e

        puts "Error scanning #{host}:#{port} - #{e.inspect}"
        cert = nil

      ensure
        ssl_client.close if ssl_client
        tcp_client.close if tcp_client
      end

      return (cert ? cert.to_der : nil)
    end

  end
end