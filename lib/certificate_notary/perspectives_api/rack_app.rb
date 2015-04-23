require 'rack'

module CertificateNotary
  module PerspectivesAPI
    class RackApp
      VALID_PARAMS = ['host', 'port', 'service_type', 'x-fp']
      VALID_FP_HASHES = ['sha256', 'md5']

      def self.call(env)
        req = Rack::Request.new(env)
        
        host = req.params['host']
        port = req.params['port'] || '443'
        service_type = req.params['service_type'] || '2'
        fp = req.params['x-fp'] || 'md5'

        return bad_request('No host given') if host.nil?
        return bad_request('Bad request') if (req.params.keys | VALID_PARAMS ).length != VALID_PARAMS.length

        return not_implemented('Unknown service type') if service_type != '2'
        return not_implemented('Unknown fingerprint hash') if not VALID_FP_HASHES.include? fp

        service = Service.find_or_create(host:host, port:port, service_type:service_type)
        service.update(last_request:Time.now)

        return service_not_found(service) if service.timespans.none?

        ScanServiceJob.enqueue_unless_exists service.id
        
        last_modified = service.timespans.last.end.httpdate

        return self.not_modified if env['HTTP_IF_MODIFIED_SINCE'] == last_modified
    
        body = XMLBuilder.xml_for_service(service, fp)
        [200, {"Content-Type" => "application/xml", "Last-Modified" => last_modified}, [body]]
      end

      def self.not_implemented(message = '')
        [501, {"Content-Type" => 'text/plain'}, [message]]
      end

      def self.bad_request(message = '')
        [400, {"Content-Type" => 'text/plain'}, [message]]
      end

      def self.service_not_found(service)
        ScanServiceJob.enqueue_unless_exists service.id, priority:50
        [404, {"Content-Type" => "text/plain"}, [""]] 
      end

      def self.not_modified
        [304, {}, []]
      end

    end
  end
end