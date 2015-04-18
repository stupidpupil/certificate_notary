require 'sucker_punch'

module PerspectivesNotary
  class ObserveJob
    include SuckerPunch::Job

    def perform(service, auto_count = 0)

      DB.transaction do
        service.lock!
        return if not service.cooled_off?
        service.update(last_observation_attempt:Time.now)
      end

      puts "Attempting observation of #{service.id_string}"
      
      fingerprint = PerspectivesNotary::OpenSSLScanner.fingerprint(service.host, service.port)
      service.observe_fingerprint(fingerprint)

      #after(Config.auto_reobserve_interval) {ObserveJob.new.perform(service, auto_count + 1)} if auto_count < Config.auto_reobserve_count
    end

  end
end