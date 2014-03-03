require 'spec_helper'

describe DynamicsCRM::XML::ColumnSet do

  describe 'initialization' do
    subject {
      DynamicsCRM::XML::ColumnSet.new(["telephone1","modifiedon","donotemail","accountid"])
    }

    context "generate ColumnSet XML" do
      it { subject.to_xml.should include("<b:AllColumns>false</b:AllColumns>") }
      it { subject.to_xml.should include("<d:string>accountid</d:string>") }
      it { subject.to_xml.should include("<d:string>donotemail</d:string>") }
      it { subject.to_xml.should include("<d:string>telephone1</d:string>") }
    end

  end

end
