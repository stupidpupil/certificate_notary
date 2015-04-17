require 'openssl'
require 'base64'

task 'generate_private_key' do
  key_length = 1369
  private_key = OpenSSL::PKey::RSA.new(key_length)

  puts Base64.strict_encode64(private_key.to_der)
end