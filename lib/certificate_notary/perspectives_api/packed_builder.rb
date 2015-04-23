module CertificateNotary
  module PerspectivesAPI
    class PackedBuilder

      def self.head_for_certificate(certificate)
        [(certificate.timespans.count >> 8) & 255, certificate.timespans.count & 255, 0, 16, 3].pack('C'*5)
      end

      def self.fingerprint_for_certificate(certificate, hash='md5')
        certificate[hash.to_sym].scan(/../).map {|h| [h.hex].pack('C')}.join
      end

      def self.timestamp_for_time(time)
        t = time.to_i
        [(t >> 24) & 255, (t >> 16) & 255, (t >> 8) & 255, t & 255].pack('C'*4)
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
        service.id_string + [0].pack('C') + service.certificates.map {|c| record_for_certificate(c, service, hash)}.inject(:+)
      end

    end
  end
end
