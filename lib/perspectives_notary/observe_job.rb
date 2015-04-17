require 'sucker_punch'

module PerspectivesNotary
  class ObserveJob
    include SuckerPunch::Job

    def perform(host, port, service_type)

      service = "#{host}:#{port},#{service_type}"
      return if not PerspectivesNotary::Observation.observation_needed_for? service
      
      fingerprint = PerspectivesNotary::OpenSSLScanner.fingerprint(host, port)
      PerspectivesNotary::Observation.observe_fingerprint(service, fingerprint)

    end

  end
end