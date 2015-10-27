require 'webrick'
require 'webrick/https'
require 'openssl'

ROOT_PATH = File.dirname(__FILE__)
CERT_PATH = ROOT_PATH + "/ssl"

ENV['RACK_ENV'] ||= 'development'

case ENV['RACK_ENV'].to_sym

when :nossl
  HOST_ADDRESS = '127.0.0.1'
  PORT_NUMBER = 8080
  SSL_ENABLE = false
  VERIFY_PEER = false

when :development
  HOST_ADDRESS = '127.0.0.1'
  PORT_NUMBER = 8443
  SSL_ENABLE = true
  VERIFY_PEER = false

when :test
  HOST_ADDRESS = '0.0.0.0'
  PORT_NUMBER = 8443
  SSL_ENABLE = true
  VERIFY_PEER = false

when :production
  HOST_ADDRESS = '0.0.0.0'
  PORT_NUMBER = 443
  SSL_ENABLE = true
  VERIFY_PEER = false

end

WEBRICK_OPTIONS = {
  :Port => PORT_NUMBER,
  :Host => HOST_ADDRESS,
  :Logger => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
  :DocumentRoot => ROOT_PATH,
  :SSLEnable => SSL_ENABLE
}

if SSL_ENABLE
  WEBRICK_OPTIONS.merge!({
    :SSLVerifyClient => VERIFY_PEER ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE,
    :SSLCertificate => OpenSSL::X509::Certificate.new(File.open(File.join(CERT_PATH, "ssl.crt")).read),
    :SSLPrivateKey => OpenSSL::PKey::RSA.new(File.open(File.join(CERT_PATH, "ssl.key")).read),
    :SSLTimeout => 5
  })

  if VERIFY_PEER
    WEBRICK_OPTIONS.merge!({
      :SSLCACertificateFile => File.join(CERT_PATH, "ClientCAs", PEER_CHAIN_NAME)
    })
  end
end

require_relative 'app'
Rack::Handler::WEBrick.run PeoplemeterStats,WEBRICK_OPTIONS
