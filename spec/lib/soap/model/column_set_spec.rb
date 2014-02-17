require 'spec_helper'

describe Mscrm::Soap::Model::ColumnSet do

  describe 'initialization' do
    subject {
      Mscrm::Soap::Model::ColumnSet.new(["telephone1","modifiedon","donotemail","accountid"])
    }

    context "generate ColumnSet XML" do
      it { subject.to_s.should include("<b:AllColumns>false</b:AllColumns>") }
      it { subject.to_s.should include("<c:string>accountid</c:string>") }
      it { subject.to_xml.should include("<c:string>donotemail</c:string>") }
      it { subject.to_xml.should include("<c:string>telephone1</c:string>") }
    end

  end

end
