require 'rack'

module PerspectivesNotary
  module PerspectivesAPI
    class RackApp
      VALID_PARAMS = ['host', 'port', 'service_type', 'x-fp']
      VALID_FP_HASHES = ['sha256', 'md5']

      def call(env)
        req = Rack::Request.new(env)
        
        host = req.params['host']
        port = req.params['port'] || '443'
        service_type = req.params['service_type'] || '2'
        fp = req.params['x-fp'] || 'md5'

        return [501, {"Content-Type" => 'text/plain'}, ['No host given']] if host.nil?
        return [501, {"Content-Type" => 'text/plain'}, ['Unknown service type']] if service_type != '2'
        return [501, {"Content-Type" => 'text/plain'}, ['Unknown fingerprint hash']] if not VALID_FP_HASHES.include? fp
        return [400, {"Content-Type" => 'text/plain'}, ['Bad request']] if (req.params.keys | VALID_PARAMS ).length != VALID_PARAMS.length

        service = nil
        DB.transaction do
          service = Service.find_or_create(host:host, port:port, service_type:service_type)
          service.update(last_request:Time.now)
        end

        if service.timespans.none?
          ScanServiceJob.enqueue service.id, priority:50
          return [404, {"Content-Type" => "text/plain"}, [""]] 
        end

        last_modified = service.timespans.last.end

        if env['HTTP_IF_MODIFIED_SINCE'] and env['HTTP_IF_MODIFIED_SINCE'] == last_modified.httpdate
          ScanServiceJob.enqueue service.id
          return [304, {}, []]
        end

        body = XMLBuilder.xml_for_service(service, fp)
        ScanServiceJob.enqueue service.id
        [200, {"Content-Type" => "application/xml", "Last-Modified" => last_modified.httpdate}, [body]]
      end
    end
  end
end