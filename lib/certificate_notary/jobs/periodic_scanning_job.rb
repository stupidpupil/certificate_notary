module CertificateNotary
  class PeriodicScanningJob < Que::Job

    def run
      CertificateNotary::DB.disconnect

      puts "Checking services for periodic scanning"

      Service.where { last_request >= Time.now-Config.auto_reobs.limit and last_observation_attempt <= Time.now-Config.auto_reobs.interval}.each do |s|
        ScanServiceJob.enqueue_unless_exists s.id
      end

      if DB[:que_jobs].where(:job_class => self.class.to_s).count == 1
        PeriodicScanningJob.enqueue run_at:(Time.now + Config.auto_reobs.period)
      end

    end
  end

end