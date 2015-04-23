$:<<'lib'

require 'rack-server-pages'
require 'certificate_notary'


class NotaryApp

  def initialize
    @perspective_api_app = CertificateNotary::PerspectivesAPI::RackApp.new
    super
  end

  def call(env)
    req = Rack::Request.new(env)
    return Rack::ServerPages.call(env) if req.params.empty?
    return @perspective_api_app.call(env)
  end

end

if CertificateNotary::DB[:que_jobs].where(:job_class => "CertificateNotary::PeriodicScanningJob").count == 0
  CertificateNotary::PeriodicScanningJob.enqueue
end

run NotaryApp.new