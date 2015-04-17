$:<<'lib'

require 'perspectives_notary'

class NotaryApp
  def call(env)

    req = Rack::Request.new(env)

    return [200, {"Content-Type" => 'text/plain'}, [PerspectivesNotary::Config.private_key.public_key.to_pem]] if req.path == '/public-key'

    host = req.params['host']
    raise "No host given!" unless host
    port = req.params['port'].to_i || 443
    service_type = req.params['service_type'].to_i || 2

    service = "#{host}:#{port},#{service_type}"

    PerspectivesNotary::ObserveJob.new.async.perform(host, port, service_type)

    return [404, {"Content-Type" => "text/plain"}, [""]] if PerspectivesNotary::DB[:observations].where(service:service).none?

    [200, {"Content-Type" => "application/xml"}, [PerspectivesNotary::XMLBuilder.xml_for_service(service)]]
  end
end

run NotaryApp.new