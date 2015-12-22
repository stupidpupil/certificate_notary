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
  class CleaningJob < Que::Job

    def self.enqueue_unless_exists(*args)
      DB[:que_jobs].where(job_class:self.to_s).any? or self.enqueue *args
    end

    def delete_orphans(model, foreign_key)
      not_orphans = Timespan.distinct.order_by(nil).select(foreign_key)
      puts "Deleted #{model.where(Sequel.~(id:not_orphans)).delete} #{model.table_name.to_s}"
      vacuum_analyze(model)
    end

    def vacuum_analyze(model)
      CertificateNotary::DB << "VACUUM (ANALYZE) #{model.table_name.to_s}"
    end

    def run
      CertificateNotary::DB.disconnect

      puts "Deleted #{Timespan.where{|t| t.end < (Date.today - Config.cleaning.clean_after)}.delete} timespans"
      vacuum_analyze(Timespan)

      if Config.cleaning.delete_orphans
        delete_orphans(Certificate, :certificate_id)
        delete_orphans(Service, :service_id)
      end

      if DB[:que_jobs].where(:job_class => self.class.to_s).count == 1
        CleaningJob.enqueue run_at:(Time.now + Config.cleaning.period)
      end

    end
  end

  CertificateNotary::DB << 'VACUUM que_jobs'
  CleaningJob.enqueue_unless_exists
end
