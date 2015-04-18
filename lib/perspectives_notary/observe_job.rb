require 'sucker_punch'

module PerspectivesNotary
  class ObserveJob
    include SuckerPunch::Job

    def perform(host, port, service_type, auto_count = 0)

      service = "#{host}:#{port},#{service_type}"

      return if not PerspectivesNotary::Observation.observation_needed_for? service
      
      fingerprint = PerspectivesNotary::OpenSSLScanner.fingerprint(host, port)
      PerspectivesNotary::Observation.observe_fingerprint(service, fingerprint)

      after(Config.auto_reobserve_interval) {ObserveJob.new.perform(host,port,service_type, auto_count + 1)} if auto_count < Config.auto_reobserve_count
    end

  end
end