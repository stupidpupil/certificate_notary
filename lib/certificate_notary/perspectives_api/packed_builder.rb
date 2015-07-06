# This file is part of the Ruby Certificate Notary.
# 
# The Ruby Certificate Notary is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# The Ruby Certificate Notary is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with the Ruby Certificate Notary.  If not, see <http://www.gnu.org/licenses/>.

module CertificateNotary
  module PerspectivesAPI

    # https://github.com/danwent/Perspectives-Server/blob/master/notary_http.py#L353-L386
    # https://github.com/danwent/Perspectives/blob/ceead359dc84fe3a1711e63b494e223917d88cba/plugin/chrome/content/xml_notary_client.js#L116-L157
    class PackedBuilder

      def self.head_for_certificate(timespans_count)
        [(timespans_count >> 8) & 255, timespans_count & 255, 0].pack('C*')
      end

      def self.fingerprint_for_certificate(hexdigest)
        ([hexdigest.length/2, 3] + hexdigest.scan(/../).map {|h| h.hex}).pack('C*')
      end

      def self.timestamp_for_time(time)
        t = time.to_i
        [(t >> 24) & 255, (t >> 16) & 255, (t >> 8) & 255, t & 255].pack('C*')
      end

      def self.timestamps_for_timespan(timespan)
        [timespan[:start], timespan[:end]].map {|t| timestamp_for_time t}.inject(:+)
      end

      def self.record_for_certificate(certificate, service, hash='md5')
        head_for_certificate(certificate.timespans.count) +
        fingerprint_for_certificate(certificate[hash.to_sym]) +
        certificate.timespans{|ds| ds.where(service:service)}.map {|ts| timestamps_for_timespan ts}.inject(:+)
      end

      def self.packed_data_for_service(service, hash='md5')
        service.id_string + [0].pack('C') + service.certificates.map {|c| record_for_certificate(c, service, hash)}.reverse.inject(:+)
      end

    end
  end
end
