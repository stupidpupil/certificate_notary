module CertificateNotary
  module PerspectivesAPI

    # https://github.com/danwent/Perspectives-Server/blob/master/notary_http.py#L353-L386
    # https://github.com/danwent/Perspectives/blob/ceead359dc84fe3a1711e63b494e223917d88cba/plugin/chrome/content/xml_notary_client.js#L116-L157
    class PackedBuilder

      def self.head_for_certificate(certificate)
        [(certificate.timespans.count >> 8) & 255, certificate.timespans.count & 255, 0].pack('C*')
      end

      def self.fingerprint_for_certificate(certificate, hash='md5')
        ([16, 3] + certificate[hash.to_sym].scan(/../).map {|h| h.hex}).pack('C*')
      end

      def self.timestamp_for_time(time)
        t = time.to_i
        [(t >> 24) & 255, (t >> 16) & 255, (t >> 8) & 255, t & 255].pack('C*')
      end

      def self.timestamps_for_timespan(timespan)
        [timespan[:start], timespan[:end]].map {|t| timestamp_for_time t}.inject(:+)
      end

      def self.record_for_certificate(certificate, service, hash='md5')
        head_for_certificate(certificate) +
        fingerprint_for_certificate(certificate, hash) +
        certificate.timespans{|ds| ds.where(service:service)}.map {|ts| timestamps_for_timespan ts}.inject(:+)
      end

      def self.packed_data_for_service(service, hash='md5')
        service.id_string + [0].pack('C') + service.certificates.map {|c| record_for_certificate(c, service, hash)}.reverse.inject(:+)
      end

    end
  end
end
