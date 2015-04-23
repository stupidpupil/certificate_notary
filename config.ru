$:<<'lib'

require 'rack-server-pages'
require 'certificate_notary'


class NotaryApp

  def call(env)
    req = Rack::Request.new(env)
    return Rack::ServerPages.call(env) if req.params.empty?
    return CertificateNotary::PerspectivesAPI::RackApp.call(env)
  end

end

if CertificateNotary::DB[:que_jobs].where(:job_class => "CertificateNotary::PeriodicScanningJob").count == 0
  CertificateNotary::PeriodicScanningJob.enqueue
end

run NotaryApp.new