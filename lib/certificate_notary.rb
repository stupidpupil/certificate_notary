require 'sequel'
Sequel.extension :migration

require 'que'

require 'base64'
require 'certificate_notary/config'

module CertificateNotary
  DB = Sequel.connect(Config.db) unless defined?(DB)
  Que.connection = DB
  Sequel::Migrator.run(DB, File.expand_path('../../migrations', __FILE__), :use_transactions=>true)
end

require 'certificate_notary/model/service'
require 'certificate_notary/model/certificate'
require 'certificate_notary/model/timespan'

require 'certificate_notary/perspectives_api/xml_builder'
require 'certificate_notary/perspectives_api/rack_app'

require 'certificate_notary/openssl_scanner'



require 'certificate_notary/jobs/scan_service_job'
require 'certificate_notary/jobs/periodic_scanning_job'