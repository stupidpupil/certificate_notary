module PerspectivesNotary
  class ObserveJob < Que::Job

    def run(service_id)

      service = Service[service_id]

      PerspectivesNotary::DB.disconnect
      
      puts "Asked to observe #{service.id_string}"
 
      DB.transaction do
        service.lock!
        return if not service.cooled_off?
        service.update(last_observation_attempt:Time.now)
      end

      puts "Scanning #{service.id_string}"

      
      der_encoded_cert = OpenSSLScanner.der_encoded_cert_for(service.host, service.port)
      service.observe_der_encoded_cert(der_encoded_cert)

    end

  end
end