require 'settingslogic'

module PerspectivesNotary
  class Config < Settingslogic
    source File.expand_path('../../../config/config.yaml', __FILE__)
    namespace ENV['RACK_ENV'] || 'development'

    def self.private_key
      @@private_key ||= OpenSSL::PKey::RSA.new(Base64.strict_decode64(Config.private_key_encoded))
    end

  end
end

