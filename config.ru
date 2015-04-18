$:<<'lib'

require 'perspectives_notary'

class NotaryApp

  def initialize
    super
    PerspectivesNotary::CheckAndReobserveJob.new.perform
  end

  def call(env)

    req = Rack::Request.new(env)

    return [200, {"Content-Type" => 'text/plain'}, [PerspectivesNotary::Config.private_key.public_key.to_pem]] if req.path == '/public-key'

    host = req.params['host']
    raise "No host given!" unless host
    port = req.params['port'] || '443'
    service_type = req.params['service_type'] || '2'

    service = nil
    PerspectivesNotary::DB.transaction do
      service = PerspectivesNotary::Service.find_or_create(host:host, port:port, service_type:service_type)
      service.update(last_request:Time.now)
    end

    PerspectivesNotary::ObserveJob.new.async.perform(service)

    return [404, {"Content-Type" => "text/plain"}, [""]] if service.timespans.none?

    [200, {"Content-Type" => "application/xml"}, [PerspectivesNotary::XMLBuilder.xml_for_service(service)]]
  end
end


run NotaryApp.new