require 'sucker_punch'

module PerspectivesNotary
  class ObserveJob
    include SuckerPunch::Job

    def perform(service, auto_count = 0)

      puts "ObserveJob #{service.id_string} #{auto_count}"

      return if not PerspectivesNotary::Observation.observation_needed_for? service
      
      fingerprint = PerspectivesNotary::OpenSSLScanner.fingerprint(service.host, service.port)
      PerspectivesNotary::Observation.observe_fingerprint(service, fingerprint)

      #after(Config.auto_reobserve_interval) {ObserveJob.new.perform(service, auto_count + 1)} if auto_count < Config.auto_reobserve_count
    end

  end
end