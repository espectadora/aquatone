module Aquatone
  module Collectors
    class Censys < Aquatone::Collector
      self.meta = {
        :name         => "Censys",
        :author       => "James McLean (@vortexau)",
        :description  => "Uses the Censys API to find hostnames in TLS certificates",
        :require_keys => ["censys","censysid"],
      }

      API_BASE_URI         = "https://www.censys.io/api/v1".freeze
      API_RESULTS_PER_PAGE = 100.freeze
      PAGES_TO_PROCESS     = 10.freeze

      def run
        request_censys_page
      end

      def request_censys_page(page=1)
          # Initial version only supporting Censys Certificates API

          # Censys expects Basic Auth for requests.
          auth = {
              :username => get_key('censysid'), 
              :password => get_key('censys')
          }
   
          # Define this is JSON content
          headers = {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
          }

          # The post body itself, as JSON
          query = {
              'query'   => url_escape("#{domain.name}"),
              'page'    => page,
              'fields'  => [ "parsed.names", "parsed.extensions.subject_alt_name.dns_names" ],
              'flatten' => true
          }

          # Search API documented at https://censys.io/api/v1/docs/search
          response = post_request(
              "#{API_BASE_URI}/search/certificates", 
              query.to_json,
              {
                  :basic_auth => auth,
                  :headers => headers 
              }
          )

          if response.code != 200
              failure(response.parsed_response["error"] || "Censys API encountered error: #{response.code}")
          end

          # Parse the actual response here.
          
          print response

      end
    end
  end
end
