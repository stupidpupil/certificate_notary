module PerspectivesNotary
  class ObserveJob < Que::Job

    def run(service_id)

      PerspectivesNotary::DB.disconnect
      
      DB.transaction do
        service = Service.for_update.first(id:service_id)
        service.lock!

        puts "Asked to observe #{service.id_string}"

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