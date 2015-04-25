module CertificateNotary
  class PeriodicScanningJob < Que::Job

    def run
      CertificateNotary::DB.disconnect

      puts "Checking services for periodic scanning"

      Service.each do |s|
        ScanServiceJob.enqueue_unless_exists(s.id) if s.cooled_off? and s.warmed_up?
      end

      if DB[:que_jobs].where(:job_class => self.class.to_s).count == 1
        PeriodicScanningJob.enqueue run_at:(Time.now + Config.periodic_scanning.period)
      end

    end
  end

end