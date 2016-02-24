require 'spec_helper'

describe DynamicsCRM::XML::ColumnSet do

  describe 'initialization' do
    subject {
      DynamicsCRM::XML::ColumnSet.new(["telephone1","modifiedon","donotemail","accountid"])
    }

    context "generate ColumnSet XML" do
      it { expect(subject.to_xml).to include("<b:AllColumns>false</b:AllColumns>") }
      it { expect(subject.to_xml).to include("<d:string>accountid</d:string>") }
      it { expect(subject.to_xml).to include("<d:string>donotemail</d:string>") }
      it { expect(subject.to_xml).to include("<d:string>telephone1</d:string>") }
    end

  end

end
