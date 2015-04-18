require 'sucker_punch'

module PerspectivesNotary
  class CheckAndReobserveJob
    include SuckerPunch::Job
    workers 2

    def perform
      PerspectivesNotary::DB.disconnect

      puts "Checking services for auto reobservation"

      Service.where { last_request >= Time.now-Config.auto_reobs.limit and last_observation_attempt <= Time.now-Config.auto_reobs.interval}.each do |s|
        ObserveJob.new.async.perform s
      end

      after(Config.auto_reobs.period) {CheckAndReobserveJob.new.perform}
    end
  end

end