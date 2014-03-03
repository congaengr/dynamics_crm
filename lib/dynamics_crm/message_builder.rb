module DynamicsCRM
  module MessageBuilder

    def uuid
      SecureRandom.uuid
    end

    def get_current_time
      Time.now.utc.strftime '%Y-%m-%dT%H:%M:%SZ'
    end

    def get_tomorrow_time
      (Time.now.utc + (24*60*60)).strftime '%Y-%m-%dT%H:%M:%SZ'
    end

    # Select the right region for your CRM
    # The region can be pulled from the Organization WSDL
    # 
    # urn:crmna:dynamics.com - North America
    # urn:crmemea:dynamics.com - Europe, the Middle East and Africa
    # urn:crmapac:dynamics.com - Asia Pacific
    def build_ocp_request(username, password)
      %Q{
        <s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope"
          xmlns:a="http://www.w3.org/2005/08/addressing"
          xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
          <s:Header>
            <a:Action s:mustUnderstand="1">http://schemas.xmlsoap.org/ws/2005/02/trust/RST/Issue</a:Action>
            <a:MessageID>urn:uuid:#{uuid()}</a:MessageID>
            <a:ReplyTo>
              <a:Address>http://www.w3.org/2005/08/addressing/anonymous</a:Address>
            </a:ReplyTo>
            <a:To s:mustUnderstand="1">#{Client::LOGIN_URL}</a:To>
            <o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
              <u:Timestamp u:Id="_0">
                <u:Created>#{get_current_time}</u:Created>
                <u:Expires>#{get_tomorrow_time}</u:Expires>
              </u:Timestamp>
              <o:UsernameToken u:Id="uuid-cdb639e6-f9b0-4c01-b454-0fe244de73af-1">
                <o:Username>#{username}</o:Username>
                <o:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">
                  #{password}
                </o:Password>
              </o:UsernameToken>
            </o:Security>
          </s:Header>
          <s:Body>
            <t:RequestSecurityToken xmlns:t="http://schemas.xmlsoap.org/ws/2005/02/trust">
              <wsp:AppliesTo xmlns:wsp="http://schemas.xmlsoap.org/ws/2004/09/policy">
                <a:EndpointReference>
                  <a:Address>#{Client::REGION}</a:Address>
                </a:EndpointReference>
              </wsp:AppliesTo>
              <t:RequestType>http://schemas.xmlsoap.org/ws/2005/02/trust/Issue</t:RequestType>
            </t:RequestSecurityToken>
          </s:Body>
        </s:Envelope>
      }
    end


    def build_envelope(action, &block)
      %Q{
       <s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
        #{build_header(action)}
        <s:Body>
          #{yield}
        </s:Body>
       </s:Envelope>
      }
    end

    def build_header(action)

      %Q{
        <s:Header>
         <a:Action s:mustUnderstand="1">http://schemas.microsoft.com/xrm/2011/Contracts/Services/IOrganizationService/#{action}</a:Action>
         <a:MessageID>
          urn:uuid:#{uuid()}
         </a:MessageID>
         <a:ReplyTo><a:Address>http://www.w3.org/2005/08/addressing/anonymous</a:Address></a:ReplyTo>
         <a:To s:mustUnderstand="1">
          #{@organization_endpoint}
         </a:To>
         <o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
         <u:Timestamp u:Id="_0">
          <u:Created>#{get_current_time}</u:Created>
          <u:Expires>#{get_tomorrow_time}</u:Expires>
         </u:Timestamp>
         <EncryptedData Id="Assertion0" Type="http://www.w3.org/2001/04/xmlenc#Element" xmlns="http://www.w3.org/2001/04/xmlenc#">
          <EncryptionMethod Algorithm="http://www.w3.org/2001/04/xmlenc#tripledes-cbc"></EncryptionMethod>
          <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
           <EncryptedKey>
            <EncryptionMethod Algorithm="http://www.w3.org/2001/04/xmlenc#rsa-oaep-mgf1p"></EncryptionMethod>
            <ds:KeyInfo Id="keyinfo">
             <wsse:SecurityTokenReference xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
              <wsse:KeyIdentifier EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary" ValueType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509SubjectKeyIdentifier">
               #{@key_identifier}
              </wsse:KeyIdentifier>
             </wsse:SecurityTokenReference>
            </ds:KeyInfo>
            <CipherData>
             <CipherValue>
              #{@security_token0}
             </CipherValue>
            </CipherData>
           </EncryptedKey>
          </ds:KeyInfo>
          <CipherData>
           <CipherValue>
            #{@security_token1}
           </CipherValue>
          </CipherData>
         </EncryptedData>
         </o:Security>
        </s:Header>
      }
    end

    def create_request(entity)
      build_envelope('Create') do
        %Q{<Create xmlns="http://schemas.microsoft.com/xrm/2011/Contracts/Services" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
            #{entity.to_xml}
        </Create>}
      end
    end

    def update_request(entity)
      build_envelope('Update') do
        %Q{<Update xmlns="http://schemas.microsoft.com/xrm/2011/Contracts/Services" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
            #{entity.to_xml}
        </Update>}
      end
    end

    # Tag name case MATTERS!
    def retrieve_request(entity_name, guid, columns)
      build_envelope('Retrieve') do
        %Q{<Retrieve xmlns="http://schemas.microsoft.com/xrm/2011/Contracts/Services">
            <entityName>#{entity_name}</entityName>
            <id>#{guid}</id>
            #{columns.to_xml}
          </Retrieve>}
      end
    end

    # Tag name case MATTERS!
    def delete_request(entity_name, guid)
      build_envelope('Delete') do
        %Q{<Delete xmlns="http://schemas.microsoft.com/xrm/2011/Contracts/Services">
            <entityName>#{entity_name}</entityName>
            <id>#{guid}</id>
          </Delete>}
      end
    end

    def associate_request(entity_name, id, relationship, relationship_entities=[])
      modify_association("Associate", entity_name, id, relationship, relationship_entities)
    end

    def disassociate_request(entity_name, id, relationship, relationship_entities=[])
      modify_association("Disassociate", entity_name, id, relationship, relationship_entities)
    end

    def modify_association(action, entity_name, id, relationship, relationship_entities=[])
      entities_xml = ""
      relationship_entities.each do |ref|
        entities_xml << ref.to_xml(namespace: "b")
      end

      build_envelope(action) do
        %Q{<#{action} xmlns="http://schemas.microsoft.com/xrm/2011/Contracts/Services" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:b="http://schemas.microsoft.com/xrm/2011/Contracts">
              <entityName i:type="string">#{entity_name}</entityName>
              <entityId xmlns:q10="http://schemas.microsoft.com/2003/10/Serialization/" i:type="q10:guid">#{id}</entityId>
              <relationship i:type="b:Relationship">
                <b:PrimaryEntityRole>Referenced</b:PrimaryEntityRole>
                <b:SchemaName i:type="string">#{relationship}</b:SchemaName>
              </relationship>
              <relatedEntities i:type="b:EntityReferenceCollection">#{entities_xml}</relatedEntities>
           </#{action}>}
      end
    end

    def execute_request(action, parameters={})

      # Default namespace is /crm/2011/Contracts
      ns_alias = "b"
      # Metadata Service calls are under the /xrm/2011/Contracts schema.
      if ["RetrieveAllEntities", "RetrieveEntityMetadata", "RetrieveEntity", "RetrieveAttribute"].include?(action)
        ns_alias = 'a'
      end

      parameters_xml = Model::Parameters.new(parameters)
      build_envelope('Execute') do
        %Q{<Execute xmlns="http://schemas.microsoft.com/xrm/2011/Contracts/Services" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
          <request i:type="#{ns_alias}:#{action}Request" xmlns:a="http://schemas.microsoft.com/xrm/2011/Contracts" xmlns:b="http://schemas.microsoft.com/crm/2011/Contracts">
           #{parameters_xml}
           <a:RequestId i:nil="true" />
           <a:RequestName>#{action}</a:RequestName>
          </request>
         </Execute>}
       end
    end

  end

end
