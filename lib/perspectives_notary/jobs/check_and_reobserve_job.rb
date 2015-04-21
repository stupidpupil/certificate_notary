module PerspectivesNotary
  class CheckAndReobserveJob < Que::Job

    def run
      PerspectivesNotary::DB.disconnect

      puts "Checking services for auto reobservation"

      Service.where { last_request >= Time.now-Config.auto_reobs.limit and last_observation_attempt <= Time.now-Config.auto_reobs.interval}.each do |s|
        ObserveJob.new.async.perform s
      end


      if DB[:que_jobs].where(:job_class => "PerspectivesNotary::CheckAndReobserveJob").count == 1
        PerspectivesNotary::CheckAndReobserveJob.enqueue run_at:(Time.now + Config.auto_reobs.period)
      end

    end
  end

end