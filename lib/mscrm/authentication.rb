require "rexml/document"
require 'curl'


# SOAP Only Walk through
# http://code.msdn.microsoft.com/CRM-Online-2011-WebServices-14913a16
#
# PHP starting point: 
# http://crmtroubleshoot.blogspot.com.au/2013/07/dynamics-crm-2011-php-and-soap-using.html
# 
# OCP: Open Commerce Platform
# https://community.dynamics.com/crm/b/crmgirishraja/archive/2012/09/04/authentication-with-dynamics-crm-online-on-ocp-office-365.aspx
class Authentication

  # The Login URL and Region are located in the client's Organization WSDL.
  # https://tinderboxdev.api.crm.dynamics.com/XRMServices/2011/Organization.svc?wsdl=wsdl0
  # 
  # Login URL: Policy -> Issuer -> Address
  # Region: SecureTokenService -> AppliesTo
  LOGIN_URL = "https://login.microsoftonline.com/RST2.srf"
  REGION = 'urn:crmna:dynamics.com';

  def initialize(username, password, hostname=nil)
    @username = username
    @password = password
    @hostname = hostname || "tinderboxdev.api.crm.dynamics.com"
    @organization_endpoint = "https://#{@hostname}/XRMServices/2011/Organization.svc"

    authenticate_user
  end

  def authenticate_user

    soap_response = post(LOGIN_URL, build_ocp_envelope)
    
    document = REXML::Document.new(soap_response)

    cipher_values = document.get_elements("//CipherValue")

    if cipher_values && cipher_values.length > 0
      @security_token0 = cipher_values[0].text
      @security_token1 = cipher_values[1].text
      # Use local-name() to ignore namespace.
      @key_identifier = document.get_elements("//[local-name() = 'KeyIdentifier']").first.text
    else
      raise RuntimeError.new(soap_response)
    end
  end

  def who_am_i

    xml = <<EOF
     <s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
      #{soap_header('Execute')}
      <s:Body>
       <Execute xmlns="http://schemas.microsoft.com/xrm/2011/Contracts/Services" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
        <request i:type="b:WhoAmIRequest" xmlns:a="http://schemas.microsoft.com/xrm/2011/Contracts" xmlns:b="http://schemas.microsoft.com/crm/2011/Contracts">
         <a:Parameters xmlns:c="http://schemas.datacontract.org/2004/07/System.Collections.Generic" />
         <a:RequestId i:nil="true" />
         <a:RequestName>WhoAmI</a:RequestName>
        </request>
       </Execute>
      </s:Body>
     </s:Envelope>
EOF

    return post(@organization_endpoint, xml)
  end

  protected


  def post(url, request)
 
puts "REQUEST"
puts request

    #"POST " . "/Organization.svc" . " HTTP/1.1",
    #"Host: tinderboxdev.api.crm.dynamics.com",

    c = Curl::Easy.new(url) do |http|
      # Set up headers.
      http.headers["Connection"] = "Keep-Alive"
      http.headers["Content-type"] = "application/soap+xml; charset=UTF-8"
      http.headers["Content-length"] = request.length

      http.ssl_verify_peer = false
      http.timeout = 60
      http.follow_location = true
      http.ssl_version = 3
      # http.verbose = 1
    end

    if c.http_post(request)
      response = c.body_str
    else

    end

    puts "RESPONSE"
    puts response

    response
  end

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
  # urn:crmna:dynamics.com - North America
  # urn:crmemea:dynamics.com - Europe, the Middle East and Africa
  # urn:crmapac:dynamics.com - Asia Pacific  
  def build_ocp_envelope

    ocp_request = <<EOF
      <s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" 
        xmlns:a="http://www.w3.org/2005/08/addressing"
        xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
        <s:Header>
          <a:Action s:mustUnderstand="1">http://schemas.xmlsoap.org/ws/2005/02/trust/RST/Issue</a:Action>
          <a:MessageID>urn:uuid:#{uuid()}</a:MessageID>
          <a:ReplyTo>
            <a:Address>http://www.w3.org/2005/08/addressing/anonymous</a:Address>
          </a:ReplyTo>
          <a:To s:mustUnderstand="1">#{LOGIN_URL}</a:To>
          <o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
            <u:Timestamp u:Id="_0">
              <u:Created>#{get_current_time}</u:Created>
              <u:Expires>#{get_tomorrow_time}</u:Expires>
            </u:Timestamp>
            <o:UsernameToken u:Id="uuid-cdb639e6-f9b0-4c01-b454-0fe244de73af-1">
              <o:Username>#{@username}</o:Username>
              <o:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">
                #{@password}
              </o:Password>
            </o:UsernameToken>
          </o:Security>
        </s:Header>
        <s:Body>
          <t:RequestSecurityToken xmlns:t="http://schemas.xmlsoap.org/ws/2005/02/trust">
            <wsp:AppliesTo xmlns:wsp="http://schemas.xmlsoap.org/ws/2004/09/policy">
              <a:EndpointReference>
                <a:Address>#{REGION}</a:Address>
              </a:EndpointReference>
            </wsp:AppliesTo>
            <t:RequestType>http://schemas.xmlsoap.org/ws/2005/02/trust/Issue</t:RequestType>
          </t:RequestSecurityToken>
        </s:Body>
      </s:Envelope>
EOF

  end


  def soap_header(action)
 
    header = <<EOF
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
EOF
 
    header

  end
 

end
