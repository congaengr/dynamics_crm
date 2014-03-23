require "dynamics_crm/version"
# CRM
require "dynamics_crm/xml/message_builder"
require 'dynamics_crm/xml/message_parser'
require "dynamics_crm/xml/fault"
require "dynamics_crm/xml/attributes"
require "dynamics_crm/xml/column_set"
require "dynamics_crm/xml/criteria"
require "dynamics_crm/xml/query"
require "dynamics_crm/xml/fetch_expression"
require "dynamics_crm/xml/entity"
require "dynamics_crm/xml/entity_reference"
require "dynamics_crm/response/result"
require "dynamics_crm/response/retrieve_result"
require "dynamics_crm/response/retrieve_multiple_result"
require "dynamics_crm/response/create_result"
require "dynamics_crm/response/execute_result"
# Metadata
require "dynamics_crm/metadata/xml_document"
require "dynamics_crm/metadata/entity_metadata"
require "dynamics_crm/metadata/attribute_metadata"
require "dynamics_crm/metadata/retrieve_all_entities_response"
require "dynamics_crm/metadata/retrieve_entity_response"
require "dynamics_crm/metadata/retrieve_attribute_response"
# Client
require "dynamics_crm/client"

require 'bigdecimal'
require 'base64'
require "rexml/document"
require 'mimemagic'
require 'curl'

module DynamicsCRM 

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
