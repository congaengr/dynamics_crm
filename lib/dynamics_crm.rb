require "dynamics_crm/version"
require "dynamics_crm/message_builder"
require "dynamics_crm/client"
# CRM
require 'dynamics_crm/model/message_parser'
require "dynamics_crm/model/fault"
require "dynamics_crm/model/attributes"
require "dynamics_crm/model/column_set"
require "dynamics_crm/model/criteria"
require "dynamics_crm/model/query"
require "dynamics_crm/model/entity"
require "dynamics_crm/model/entity_reference"
require "dynamics_crm/model/result"
require "dynamics_crm/model/retrieve_result"
require "dynamics_crm/model/retrieve_multiple_result"
require "dynamics_crm/model/create_result"
require "dynamics_crm/model/execute_result"
# Metadata
require "dynamics_crm/metadata/xml_document"
require "dynamics_crm/metadata/entity_metadata"
require "dynamics_crm/metadata/attribute_metadata"
require "dynamics_crm/metadata/retrieve_all_entities_response"
require "dynamics_crm/metadata/retrieve_entity_response"
require "dynamics_crm/metadata/retrieve_attribute_response"

require 'bigdecimal'
require 'nokogiri'
require "rexml/document"
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
