# Copyright (c) 2012 SnowPlow Analytics Ltd. All rights reserved.
#
# This program is licensed to you under the Apache License Version 2.0,
# and you may not use this file except in compliance with the Apache License Version 2.0.
# You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the Apache License Version 2.0 is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.

# Author::    Yali Sassoon (mailto:support@snowplowanalytics.com)
# Copyright:: Copyright (c) 2012 SnowPlow Analytics Ltd
# License::   Apache License Version 2.0

require 'uri'
require 'cgi'

module RefererParser
    class Parser

        attr_reader :uri,
                    :known,
                    :referer,
                    :parameter,
                    :keywords

        # So can be interrogated with .known? too.
        alias_method :known?, :known

        def initialize(referer_url)

            @uri = parse_uri(referer_url)

            referer = Referer.get_referer(@uri)
            unless referer.nil?
                @known = true
                @referer = referer['name']
                [@parameter, @keywords] = get_parameter_and_keywords(@uri, referer['parameters'])
            else
                @known = false
                @referer, @parameter = nil # Being explicit
                @keywords = []
            end
        end

        private # -------------------------------------------------------------

        # Static method to turn a `raw_url`
        # into a URI, checking that it's
        # a HTTP(S) URI
        def self.parse_uri(raw_url)
            uri = URI.parse(raw_url)
            
            unless %w( http https ).include?(uri.scheme)
                raise ArgumentError, "'#{raw_url}' is not an http(s) protocol url"
            end
            uri
        end

        # Static method to get the keywords from a `url`,
        # where keywords are stored against one of the
        # `possible_parameters` in the querystring.
        # Returns a 'tuple' of the parameter found plus
        # the keywords.
        def self.get_parameter_and_keywords(url, possible_parameters)

            # Only get keywords if there's a query string to extract them from...
            if url.query
                parameters = CGI.parse(url.query)

                # Try each possible keyword parameter with the querystring until one returns a result
                possible_parameters.each do | pp |
                    if parameters.has_key?(pp)
                        return [pp, parameters[pp]]
                    end
                end
            end

            return [nil, []] # No parameter or keywords to return
        end
    end
end