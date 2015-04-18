module PerspectivesNotary
  class Service < Sequel::Model
    one_to_many :observations

    def id_string
      return "#{host}:#{port},#{service_type}"
    end

    def cooled_off?
      return true if last_observation_attempt.nil?
      return true if (last_observation_attempt+Config.observation_cool_off) < Time.now
      false
    end

    def observe_fingerprint(fingerprint)
      Observation.observe_fingerprint(self, fingerprint)
    end

  end
end