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