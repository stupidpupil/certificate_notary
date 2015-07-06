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

require 'certificate_notary/perspectives_api/packed_builder'
require 'certificate_notary/perspectives_api/xml_builder'
require 'certificate_notary/perspectives_api/rack_app'

require 'certificate_notary/openssl_scanner'



require 'certificate_notary/jobs/scan_service_job'
require 'certificate_notary/jobs/periodic_scanning_job'