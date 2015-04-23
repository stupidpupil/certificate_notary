$:<<'lib'

require 'rack-server-pages'
require 'perspectives_notary'


class NotaryApp

  def initialize
    @perspective_api_app = PerspectivesNotary::PerspectivesAPI::RackApp.new
    super
  end

  def call(env)
    req = Rack::Request.new(env)
    return Rack::ServerPages.call(env) if req.params.empty?
    return @perspective_api_app.call(env)
  end

end

if PerspectivesNotary::DB[:que_jobs].where(:job_class => "PerspectivesNotary::PeriodicScanningJob").count == 0
  PerspectivesNotary::PeriodicScanningJob.enqueue
end

run NotaryApp.new