module PerspectivesNotary
  class PeriodicScanningJob < Que::Job

    def run
      PerspectivesNotary::DB.disconnect

      puts "Checking services for periodic scanning"

      Service.where { last_request >= Time.now-Config.auto_reobs.limit and last_observation_attempt <= Time.now-Config.auto_reobs.interval}.each do |s|
        ScanServiceJob.enqueue s.id
      end


      if DB[:que_jobs].where(:job_class => "PerspectivesNotary::PeriodicScanningJob").count == 1
        PerspectivesNotary::PeriodicScanningJob.enqueue run_at:(Time.now + Config.auto_reobs.period)
      end

    end
  end

end