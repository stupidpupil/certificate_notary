module CertificateNotary
  class PeriodicScanningJob < Que::Job

    def self.enqueue_unless_exists(*args)
      DB[:que_jobs].where(job_class:self.to_s).any? or self.enqueue *args
    end

    def run
      CertificateNotary::DB.disconnect

      puts "Checking services for periodic scanning"

      Service.each do |s|
        ScanServiceJob.enqueue_unless_exists(s.id) if s.needs_periodic_scanning?
      end

      if DB[:que_jobs].where(:job_class => self.class.to_s).count == 1
        PeriodicScanningJob.enqueue run_at:(Time.now + Config.periodic_scanning.period)
      end

    end
  end

  PeriodicScanningJob.enqueue_unless_exists
end
