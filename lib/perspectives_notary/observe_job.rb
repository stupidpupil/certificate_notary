require 'sucker_punch'

module PerspectivesNotary
  class ObserveJob
    include SuckerPunch::Job
    workers 4

    def perform(service)

      puts "Attempting observation of #{service.id_string}"
 
      DB.transaction do
        service.lock!
        return if not service.cooled_off?
        service.update(last_observation_attempt:Time.now)
      end

      puts "Scanning #{service.id_string}"

      
      der_encoded_cert = PerspectivesNotary::OpenSSLScanner.der_encoded_cert_for(service.host, service.port)
      service.observe_der_encoded_cert(der_encoded_cert)

    end

  end
end