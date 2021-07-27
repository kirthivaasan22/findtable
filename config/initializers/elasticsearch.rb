require 'typhoeus'
require 'typhoeus/adapters/faraday'
require 'elasticsearch'

$es = Elasticsearch::Client.new host: Rails.application.secrets[:elasticsearch][:hosts], log: false