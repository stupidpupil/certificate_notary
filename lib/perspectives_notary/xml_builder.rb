module PerspectivesNotary
  class XMLBuilder

    def self.xml_for_service(service, fp='md5')
      xml = ""
      packed_data = ""

      service.certificates_dataset.eager(:timespans).all.each do |certificate|

        fp = certificate[fp.to_sym].scan(/../).join(':')
        timestamps = certificate.timespans

        #
        # Packed Data
        #

        head = [(timestamps.count >> 8) & 255, timestamps.count & 255, 0, 16, 3].pack('C'*5)
        fp_bytes = fp.split(':').map {|h| [h.hex].pack('C')}.join
        
        ts_bytes = ""
        timestamps.each do |ts|
          [ts[:start].to_i, ts[:end].to_i].each do |t|
            ts_bytes << [(t >> 24) & 255, (t >> 16) & 255, (t >> 8) & 255, t & 255].pack('C'*4)
          end
        end

        packed_data = (head + fp_bytes + ts_bytes) + packed_data

        #
        # Key Element
        #

        xml << "<key fp=\"#{fp}\" type=\"ssl\">"
        xml << timestamps.map {|ts| "<timestamp end=\"#{ts[:end].to_i}\" start=\"#{ts[:start].to_i}\"/>" }.join("\n")
        xml << "</key>"

      end

      packed_data = service.id_string + [0].pack('C') + packed_data
      signature =  Base64.strict_encode64(Config.private_key.sign(OpenSSL::Digest::MD5.new, packed_data))

      return "<notary_reply sig=\"#{signature}\" sig_type=\"rsa-md5\" version=\"1\">#{xml}</notary_reply>"

    end

  end
end