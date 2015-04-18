module PerspectivesNotary
  class Observation < Sequel::Model(DB[:observations].order(Sequel.asc(:end)))
    many_to_one :service

    def self.observe_fingerprint(service, fingerprint)
      most_recent_obs = Observation.where(service: service).last

      if most_recent_obs.nil? or most_recent_obs.fingerprint != fingerprint or (Time.now - most_recent_obs[:end]) > Config.observation_update_limit
        return Observation.create(service:service, fingerprint:fingerprint, start:Time.now, end:Time.now)
      else
        most_recent_obs.update(end:Time.now)
      end

    end

  end
end