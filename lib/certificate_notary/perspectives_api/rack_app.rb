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

require 'rack'

module CertificateNotary
  module PerspectivesAPI
    class RackApp
      VALID_PARAMS = ['host', 'port', 'service_type', 'x-fp']
      VALID_FP_HASHES = ['sha256', 'md5']

      DEFAULTS ={ 'port' => '443', 'service_type' => '2', 'x-fp' => 'md5'}

      def self.call(env)
        req = Rack::Request.new(env)
        
        req.params.merge!(DEFAULTS) {|k,p,d| p}

        return bad_request('No host given') if req.params['host'].nil?
        return bad_request('Bad request') if (req.params.keys - VALID_PARAMS ).any?
        return bad_request('Invalid port number') if not req.params['port'].to_i.between? 1,65535

        return not_implemented('Unknown service type') if req.params['service_type'] != '2'
        return not_implemented('Unknown fingerprint hash') if not VALID_FP_HASHES.include? req.params['x-fp']

        valid_request(req)
      end

      def self.bad_request(message = '')
        [400, {"Content-Type" => 'text/plain'}, [message]]
      end

      def self.not_implemented(message = '')
        [501, {"Content-Type" => 'text/plain'}, [message]]
      end


      def self.valid_request(req)
        service = service_with_request req

        return not_found(service) if service.timespans.none?

        last_modified = service.timespans.last.end.httpdate
        
        return not_modified(service) if req.env['HTTP_IF_MODIFIED_SINCE'] == last_modified
    
        ScanServiceJob.enqueue_unless_exists service.id
        body = XMLBuilder.xml_for_service(service, req.params['x-fp'])
        [200, {"Content-Type" => "application/xml", "Last-Modified" => last_modified}, [body]]
      end

      def self.service_with_request(req)
        service = Service.find_or_create(host:req['host'], port:req['port'], service_type:req['service_type'])
        service.update(last_request:Time.now)
      end

      def self.not_found(service)
        ScanServiceJob.enqueue_unless_exists service.id, priority:50
        [404, {"Content-Type" => "text/plain"}, [""]] 
      end

      def self.not_modified(service)
        ScanServiceJob.enqueue_unless_exists service.id
        [304, {}, []]
      end

    end
  end
end