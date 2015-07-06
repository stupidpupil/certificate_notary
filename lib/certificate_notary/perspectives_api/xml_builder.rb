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
    class XMLBuilder

      def self.xml_for_service(service, hash='md5')
        xml = ""

        service.certificates.each do |certificate|

          fp = certificate[hash.to_sym].scan(/../).join(':')

          xml << "<key fp=\"#{fp}\" type=\"ssl\">"
          xml << certificate.timespans{|ds| ds.where(service:service)}.map {|ts| "<timestamp end=\"#{ts[:end].to_i}\" start=\"#{ts[:start].to_i}\"/>" }.join("\n")
          xml << "</key>"

        end

        packed_data = PackedBuilder.packed_data_for_service(service, hash)
        signature =  Base64.strict_encode64(Config.private_key.sign(OpenSSL::Digest::MD5.new, packed_data))

        return "<notary_reply sig=\"#{signature}\" sig_type=\"rsa-md5\" version=\"1\">#{xml}</notary_reply>"

      end

    end
  end
end