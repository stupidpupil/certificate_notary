require 'sequel'
Sequel.extension :migration

require 'base64'
require 'perspectives_notary/config'

module PerspectivesNotary
  DB = Sequel.connect(Config.db) unless defined?(DB)
  Sequel::Migrator.run(DB, File.expand_path('../../migrations', __FILE__), :use_transactions=>true)
end

require 'perspectives_notary/xml_builder'
require 'perspectives_notary/openssl_scanner'
require 'perspectives_notary/observation'