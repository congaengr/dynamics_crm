require "mscrm/soap/version"
require "mscrm/soap/message_builder"
require "mscrm/soap/client"
# CRM
require 'mscrm/soap/model/message_parser'
require "mscrm/soap/model/fault"
require "mscrm/soap/model/attributes"
require "mscrm/soap/model/column_set"
require "mscrm/soap/model/criteria"
require "mscrm/soap/model/query"
require "mscrm/soap/model/entity"
require "mscrm/soap/model/entity_reference"
require "mscrm/soap/model/result"
require "mscrm/soap/model/retrieve_result"
require "mscrm/soap/model/retrieve_multiple_result"
require "mscrm/soap/model/create_result"
require "mscrm/soap/model/execute_result"
# Metadata
require "mscrm/soap/metadata/entity_metadata"
require "mscrm/soap/metadata/retrieve_all_entities_response"
require "mscrm/soap/metadata/retrieve_entity_response"


require "rexml/document"
require 'savon'
require 'curl'

module Mscrm
  module Soap

    class StringUtil
      def self.underscore(str)
        str.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
      end
    end

  end
end
