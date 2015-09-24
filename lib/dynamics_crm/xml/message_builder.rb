module DynamicsCRM
  module XML
    module MessageBuilder

      def uuid
        SecureRandom.uuid
      end

      # have a bit of flexiblity in the create time to handle when system clocks are out of sync
      def get_current_time
        # 5.minutes = 5 * 60
        (Time.now - (5 * 60)).utc.strftime '%Y-%m-%dT%H:%M:%SZ'
      end

      def get_current_time_plus_hour
        (Time.now.utc + (60*60)).strftime '%Y-%m-%dT%H:%M:%SZ'
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
      def build_ocp_request(username, password, region = "urn:crmna:dynamics.com", login_url = Client::OCP_LOGIN_URL)
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
              <a:To s:mustUnderstand="1">#{login_url}</a:To>
              <o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
                <u:Timestamp u:Id="_0">
                  <u:Created>#{get_current_time}</u:Created>
                  <u:Expires>#{get_tomorrow_time}</u:Expires>
                </u:Timestamp>
                <o:UsernameToken u:Id="uuid-cdb639e6-f9b0-4c01-b454-0fe244de73af-1">
                  <o:Username>#{REXML::Text.new(username).to_s}</o:Username>
                  <o:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">
                    #{REXML::Text.new(password).to_s}
                  </o:Password>
                </o:UsernameToken>
              </o:Security>
            </s:Header>
            <s:Body>
              <t:RequestSecurityToken xmlns:t="http://schemas.xmlsoap.org/ws/2005/02/trust">
                <wsp:AppliesTo xmlns:wsp="http://schemas.xmlsoap.org/ws/2004/09/policy">
                  <a:EndpointReference>
                    <a:Address>#{region}</a:Address>
                  </a:EndpointReference>
                </wsp:AppliesTo>
                <t:RequestType>http://schemas.xmlsoap.org/ws/2005/02/trust/Issue</t:RequestType>
              </t:RequestSecurityToken>
            </s:Body>
          </s:Envelope>
        }
      end

      def build_on_premise_request(username, password, region = "", login_url = nil)
        %Q{
          <s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope"
            xmlns:a="http://www.w3.org/2005/08/addressing">
            <s:Header>
              <a:Action s:mustUnderstand="1">http://docs.oasis-open.org/ws-sx/ws-trust/200512/RST/Issue</a:Action>
              <a:MessageID>urn:uuid:#{uuid()}</a:MessageID>
              <a:ReplyTo>
                <a:Address>http://www.w3.org/2005/08/addressing/anonymous</a:Address>
              </a:ReplyTo>
              <Security s:mustUnderstand="1" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
                <u:Timestamp u:Id="#{uuid()}">
                  <u:Created>#{get_current_time}</u:Created>
                  <u:Expires>#{get_current_time_plus_hour}</u:Expires>
                </u:Timestamp>
                <UsernameToken u:Id="#{uuid()}">
                  <Username>#{REXML::Text.new(username).to_s}</Username>
                  <Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">#{REXML::Text.new(password).to_s}</Password>
                </UsernameToken>
              </Security>
              <a:To s:mustUnderstand="1">#{login_url}</a:To>
            </s:Header>
            <s:Body>
              <trust:RequestSecurityToken xmlns:trust="http://docs.oasis-open.org/ws-sx/ws-trust/200512">
                <wsp:AppliesTo xmlns:wsp="http://schemas.xmlsoap.org/ws/2004/09/policy">
                  <a:EndpointReference>
                    <a:Address>#{region}</a:Address>
                  </a:EndpointReference>
                </wsp:AppliesTo>
                <trust:RequestType>http://docs.oasis-open.org/ws-sx/ws-trust/200512/Issue</trust:RequestType>
              </trust:RequestSecurityToken>
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
        if @on_premise
          build_on_premise_header(action)
        else
          build_ocp_header(action)
        end
      end

      def build_on_premise_header(action)
        %Q{
          <s:Header>
            <a:Action s:mustUnderstand="1">http://schemas.microsoft.com/xrm/2011/Contracts/Services/IOrganizationService/#{action}</a:Action>
            <a:MessageID>urn:uuid:#{uuid()}</a:MessageID>
            <a:ReplyTo>
              <a:Address>http://www.w3.org/2005/08/addressing/anonymous</a:Address>
            </a:ReplyTo>
            <a:To s:mustUnderstand="1">#{@organization_endpoint}</a:To>
            <o:Security xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
              #{@timestamp}
              <xenc:EncryptedData Type="http://www.w3.org/2001/04/xmlenc#Element" xmlns:xenc="http://www.w3.org/2001/04/xmlenc#">
                <xenc:EncryptionMethod Algorithm="http://www.w3.org/2001/04/xmlenc#aes256-cbc"/>
                <KeyInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
                  <e:EncryptedKey xmlns:e="http://www.w3.org/2001/04/xmlenc#">
                    <e:EncryptionMethod Algorithm="http://www.w3.org/2001/04/xmlenc#rsa-oaep-mgf1p">
                      <DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>
                    </e:EncryptionMethod>
                    <KeyInfo>
                      <o:SecurityTokenReference xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
                        <X509Data>
                          <X509IssuerSerial>
                            <X509IssuerName>#{@cert_issuer_name}</X509IssuerName>
                            <X509SerialNumber>#{@cert_serial_number}</X509SerialNumber>
                          </X509IssuerSerial>
                        </X509Data>
                      </o:SecurityTokenReference>
                    </KeyInfo>
                    <e:CipherData>
                      <e:CipherValue>#{@security_token0}</e:CipherValue>
                    </e:CipherData>
                  </e:EncryptedKey>
                </KeyInfo>
                <xenc:CipherData>
                  <xenc:CipherValue>#{@security_token1}</xenc:CipherValue>
                </xenc:CipherData>
              </xenc:EncryptedData>
              <Signature xmlns="http://www.w3.org/2000/09/xmldsig#">
                #{@signature}
                <SignatureValue>#{@signature_value}</SignatureValue>
                <KeyInfo>
                  <o:SecurityTokenReference xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
                    <o:KeyIdentifier ValueType="http://docs.oasis-open.org/wss/oasis-wss-saml-token-profile-1.0#SAMLAssertionID">#{@key_identifier}</o:KeyIdentifier>
                  </o:SecurityTokenReference>
                </KeyInfo>
              </Signature>
            </o:Security>
          </s:Header>
        }
      end

      def build_ocp_header(action)
        caller_id = @caller_id ? %Q{<CallerId xmlns="http://schemas.microsoft.com/xrm/2011/Contracts">#{@caller_id}</CallerId>} : ""
        %Q{
          <s:Header>
           <a:Action s:mustUnderstand="1">http://schemas.microsoft.com/xrm/2011/Contracts/Services/IOrganizationService/#{action}</a:Action>
           #{caller_id}
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

      def retrieve_multiple_request(object)
        request = build_envelope('RetrieveMultiple') do
          %Q{
          <RetrieveMultiple xmlns="http://schemas.microsoft.com/xrm/2011/Contracts/Services">
            #{object.to_xml}
          </RetrieveMultiple>
          }
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
          entities_xml << ref.to_xml(namespace: "b", camel_case: true)
        end

        build_envelope(action) do
          %Q{<#{action} xmlns="http://schemas.microsoft.com/xrm/2011/Contracts/Services" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:b="http://schemas.microsoft.com/xrm/2011/Contracts">
                <entityName i:type="string">#{entity_name}</entityName>
                <entityId xmlns:q10="http://schemas.microsoft.com/2003/10/Serialization/" i:type="q10:guid">#{id}</entityId>
                <relationship i:type="b:Relationship">
                  <b:PrimaryEntityRole i:nil="true" />
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
        if ["RetrieveAllEntities", "RetrieveEntityMetadata", "RetrieveEntity", "RetrieveAttribute", "RetrieveMultiple", "RetrieveMetadataChanges"].include?(action)
          ns_alias = 'a'
        end

        parameters = XML::Parameters.new(parameters)
        build_envelope('Execute') do
          %Q{<Execute xmlns="http://schemas.microsoft.com/xrm/2011/Contracts/Services" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
            <request i:type="#{ns_alias}:#{action}Request" xmlns:a="http://schemas.microsoft.com/xrm/2011/Contracts" xmlns:b="http://schemas.microsoft.com/crm/2011/Contracts">
             #{parameters.to_xml}
             <a:RequestId i:nil="true" />
             <a:RequestName>#{action}</a:RequestName>
            </request>
           </Execute>}
         end
      end

    end
    # MessageBuilder
  end
end
