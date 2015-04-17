module PerspectivesNotary
  class Observation < Sequel::Model

    def self.observe_fingerprint(service, fingerprint)
      fp = DB[:observations].where(service: service, fingerprint:fingerprint).order(Sequel.desc(:end)).first

      if fp.nil? or (Time.now - fp[:end]) > Config.observation_update_limit
        DB[:observations].insert(service: service, fingerprint: fingerprint, start:Time.now, end:Time.now)
      else
        DB[:observations].where(id:fp[:id]).update(end:Time.now)
      end

    end

    def self.observation_needed_for?(service)
      return true if DB[:observations].where(service:service).none?
      return true if DB[:observations].where(service:service).all.max {|o| o[:end]}[:end] < (Time.now - Config.observation_cool_off) 
      return false
    end

  end
end