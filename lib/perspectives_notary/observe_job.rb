require 'sucker_punch'

module PerspectivesNotary
  class ObserveJob
    include SuckerPunch::Job

    def perform(service)

      DB.transaction do
        service.lock!
        return if not service.cooled_off?
        service.update(last_observation_attempt:Time.now)
      end

      puts "Attempting observation of #{service.id_string}"
      
      fingerprint = PerspectivesNotary::OpenSSLScanner.fingerprint(service.host, service.port)
      service.observe_fingerprint(fingerprint)

      if ((Time.now+Config.auto_reobserve_limit)-service.last_request) < Config.auto_reobserve_limit
        after(Config.auto_reobserve_interval) {ObserveJob.new.perform(service)}
      end

    end

  end
end