require "dynamics_crm/version"
# CRM
require "dynamics_crm/xml/message_builder"
require 'dynamics_crm/xml/message_parser'
require "dynamics_crm/xml/fault"
require "dynamics_crm/xml/attributes"
require "dynamics_crm/xml/condition_expression"
require "dynamics_crm/xml/column_set"
require "dynamics_crm/xml/criteria"
require "dynamics_crm/xml/query_expression"
require "dynamics_crm/xml/filter_expression"
require "dynamics_crm/xml/fetch_expression"
require "dynamics_crm/xml/entity"
require "dynamics_crm/xml/entity_reference"
require "dynamics_crm/xml/entity_collection"
require "dynamics_crm/xml/money"
require "dynamics_crm/xml/page_info"
require "dynamics_crm/response/result"
require "dynamics_crm/response/retrieve_result"
require "dynamics_crm/response/retrieve_multiple_result"
require "dynamics_crm/response/create_result"
require "dynamics_crm/response/execute_result"
# Metadata
require "dynamics_crm/metadata/xml_document"
require "dynamics_crm/metadata/one_to_many_relationship"
require "dynamics_crm/metadata/relationship_metadata"
require "dynamics_crm/metadata/entity_metadata"
require "dynamics_crm/metadata/attribute_metadata"
require "dynamics_crm/metadata/attribute_query_expression"
require "dynamics_crm/metadata/filter_expression"
require "dynamics_crm/metadata/properties_expression"
require "dynamics_crm/metadata/entity_query_expression"
require "dynamics_crm/metadata/retrieve_all_entities_response"
require "dynamics_crm/metadata/retrieve_entity_response"
require "dynamics_crm/metadata/retrieve_attribute_response"
require "dynamics_crm/metadata/retrieve_metadata_changes_response"
require "dynamics_crm/metadata/double"
# Model
require "dynamics_crm/model/entity"
require "dynamics_crm/model/opportunity"
# Fetch XML
require "dynamics_crm/fetch_xml/entity"
require 'dynamics_crm/fetch_xml/link_entity'
require "dynamics_crm/fetch_xml/builder"
# Client
require "dynamics_crm/client"

require 'bigdecimal'
require 'base64'
require "rexml/document"
require 'net/https'
require 'mimemagic'
require 'securerandom'
require 'date'
require 'cgi'

module DynamicsCRM

  class StringUtil
    def self.underscore(str)
      str.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end

    def self.valueOf(text)
      # Convert text to actual data types.
      value = text
      if value == "true" || value == "false"
        value = (value == "true")
      elsif value =~ /^[-?]\d+$/
        value = value.to_i
      elsif value =~ /^[-?]\d+\.\d+$/
        value = value.to_f
      else
        value
      end
    end
  end

end
