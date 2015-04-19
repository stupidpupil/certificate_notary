module PerspectivesNotary
  class Service < Sequel::Model
    one_to_many :timespans

    def id_string
      return "#{host}:#{port},#{service_type}"
    end

    def cooled_off?
      return true if last_observation_attempt.nil?
      return true if (last_observation_attempt+Config.observation_cool_off) < Time.now
      false
    end

    def observe_der_encoded_cert(der_encoded_cert)

      return if der_encoded_cert.nil?

      certificate = Certificate.with_der_encoded_cert(der_encoded_cert)

      most_recent_obs = Timespan.where(service: self).last

      if most_recent_obs.nil? or most_recent_obs.certificate != certificate or (Time.now - most_recent_obs[:end]) > Config.observation_update_limit
        return Timespan.create(service:self, certificate:certificate, start:Time.now, end:Time.now)
      else
        most_recent_obs.update(end:Time.now)
      end

    end

  end
end