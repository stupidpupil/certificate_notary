module CertificateNotary
  module PerspectivesAPI
    class XMLBuilder

      def self.xml_for_service(service, hash='md5')
        xml = ""

        service.certificates.each do |certificate|

          fp = certificate[hash.to_sym].scan(/../).join(':')

          xml << "<key fp=\"#{fp}\" type=\"ssl\">"
          xml << certificate.timespans.map {|ts| "<timestamp end=\"#{ts[:end].to_i}\" start=\"#{ts[:start].to_i}\"/>" }.join("\n")
          xml << "</key>"

        end

        packed_data = XMLBuilder.packed_data_for_service(service, hash)
        signature =  Base64.strict_encode64(Config.private_key.sign(OpenSSL::Digest::MD5.new, packed_data))

        return "<notary_reply sig=\"#{signature}\" sig_type=\"rsa-md5\" version=\"1\">#{xml}</notary_reply>"

      end

      def self.packed_data_for_service(service, hash='md5')
        packed_data = ""

        service.certificates.each do |certificate|

          head = [(certificate.timespans.count >> 8) & 255, certificate.timespans.count & 255, 0, 16, 3].pack('C'*5)
          fp_bytes = certificate[hash.to_sym].scan(/../).map {|h| [h.hex].pack('C')}.join
          
          ts_bytes = ""
          certificate.timespans.each do |ts|
            [ts[:start].to_i, ts[:end].to_i].each do |t|
              ts_bytes << [(t >> 24) & 255, (t >> 16) & 255, (t >> 8) & 255, t & 255].pack('C'*4)
            end
          end

          packed_data = (head + fp_bytes + ts_bytes) + packed_data

        end

        return service.id_string + [0].pack('C') + packed_data

      end

    end
  end
end