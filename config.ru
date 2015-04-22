$:<<'lib'

require 'rack-server-pages'
require 'perspectives_notary'


class NotaryApp

  VALID_PARAMS = ['host', 'port', 'service_type', 'x-fp']
  VALID_FP_HASHES = ['sha256', 'md5']

  def initialize
    super
  end

  def call(env)

    req = Rack::Request.new(env)

    return Rack::ServerPages.call(env) if req.params.empty?

    host = req.params['host']
    port = req.params['port'] || '443'
    service_type = req.params['service_type'] || '2'
    fp = req.params['x-fp'] || 'md5'

    return [501, {"Content-Type" => 'text/plain'}, ['Unknown service type']] if service_type != '2'
    return [501, {"Content-Type" => 'text/plain'}, ['Unknown fingerprint hash']] if not VALID_FP_HASHES.include? fp
    return [400, {"Content-Type" => 'text/plain'}, ['Bad request']] if (req.params.keys | VALID_PARAMS ).length != VALID_PARAMS.length

    service = nil
    PerspectivesNotary::DB.transaction do
      service = PerspectivesNotary::Service.find_or_create(host:host, port:port, service_type:service_type)
      service.update(last_request:Time.now)
    end

    if service.timespans.none?
      PerspectivesNotary::ObserveJob.enqueue service.id, priority:50
      return [404, {"Content-Type" => "text/plain"}, [""]] 
    end
    
    PerspectivesNotary::ObserveJob.enqueue service.id
    [200, {"Content-Type" => "application/xml"}, [PerspectivesNotary::XMLBuilder.xml_for_service(service, fp)]]
  end
end

if PerspectivesNotary::DB[:que_jobs].where(:job_class => "PerspectivesNotary::CheckAndReobserveJob").count == 0
  PerspectivesNotary::CheckAndReobserveJob.enqueue
end

run NotaryApp.new