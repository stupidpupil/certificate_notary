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
  class ScanServiceJob < Que::Job

    def self.enqueue_unless_exists(service_id, *args)
      return unless DB[:que_jobs].where(job_class:self.to_s).where('args->>0 = ?', service_id.to_s).none?
      self.enqueue service_id, *args
    end

    def run(service_id)

      DB.disconnect
      
      DB.transaction do
        service = Service.for_update.first(id:service_id)
        service.lock!

        destroy and return if not service.cooled_off?
        
        service.update(last_observation_attempt:Time.now)
        puts "Scanning #{service.id_string}"

        der_encoded_cert = OpenSSLScanner.der_encoded_cert_for(service.host, service.port)
        service.observe_der_encoded_cert(der_encoded_cert)

        destroy
      end

    end

  end
end