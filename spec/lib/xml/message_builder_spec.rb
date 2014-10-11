require 'spec_helper'

describe DynamicsCRM::XML::MessageBuilder do

  describe 'execute_request' do
    let(:dummy_class) { Class.new.extend(DynamicsCRM::XML::MessageBuilder) }

    context "who_am_i" do
      it "generates WhoAmI XML request" do
        xml = dummy_class.execute_request('WhoAmI')
        expect(xml).to include('<request i:type="b:WhoAmIRequest"')
        expect(xml).to include('<a:Parameters xmlns:c="http://schemas.datacontract.org/2004/07/System.Collections.Generic">')
      end
    end

  end

end
