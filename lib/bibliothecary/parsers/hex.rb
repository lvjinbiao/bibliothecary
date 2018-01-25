require 'json'

module Bibliothecary
  module Parsers
    class Hex
      include Bibliothecary::Analyser

      def self.mapping
        {
          /^mix\.exs$/ => {
            kind: 'manifest',
            parser: :parse_mix
          },
          /^mix\.lock$/ => {
            kind: 'lockfile',
            parser: :parse_mix_lock
          }
        }
      end

      def self.parse_mix(manifest)
        response = Typhoeus.post("#{Bibliothecary.configuration.mix_parser_host}/", body: manifest)
        json = JSON.parse response.body

        json.map do |name, version|
          {
            name: name,
            requirement: version,
            type: "runtime"
          }
        end
      end

      def self.parse_mix_lock(manifest)
        response = Typhoeus.post("#{Bibliothecary.configuration.mix_parser_host}/lock", body: manifest)
        json = JSON.parse response.body

        json.map do |name, info|
          {
            name: name,
            requirement: info['version'],
            type: "runtime"
          }
        end
      end
    end
  end
end
