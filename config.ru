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

run NotaryApp.new