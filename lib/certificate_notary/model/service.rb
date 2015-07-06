# This file is part of the Ruby Certificate Notary.
# 
# The Ruby Certificate Notary is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# The Ruby Certificate Notary is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with the Ruby Certificate Notary.  If not, see <http://www.gnu.org/licenses/>.

module CertificateNotary
  class Service < Sequel::Model
    one_to_many :timespans
    many_to_many :certificates, :join_table => :timespans

    def id_string
      return "#{host}:#{port},#{service_type}"
    end

    def cooled_off?
      return true if last_observation_attempt.nil?
      return true if (last_observation_attempt + Config.scanning.cool_off) < Time.now
      false
    end

    def warmed_up?
      return true if last_request.nil?
      return true if (Time.now - last_request) < Config.periodic_scanning.limit
      false
    end

    def needs_periodic_scanning?
      return warmed_up? if last_observation_attempt.nil?
      return warmed_up? if (last_observation_attempt + Config.periodic_scanning.interval) < Time.now
      false
    end

    def observe_der_encoded_cert(der_encoded_cert)

      return if der_encoded_cert.nil?

      certificate = Certificate.with_der_encoded_cert(der_encoded_cert)

      most_recent_obs = Timespan.where(service: self).last

      if most_recent_obs.nil? or most_recent_obs.certificate != certificate or (Time.now - most_recent_obs[:end]) > Config.timespan_update_limit
        return Timespan.create(service:self, certificate:certificate, start:Time.now, end:Time.now)
      else
        most_recent_obs.update(end:Time.now)
      end

    end

  end
end