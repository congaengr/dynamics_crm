require 'spec_helper'

describe DynamicsCRM::Model::ExecuteResult do

  describe 'who_am_i' do
    subject {
      file = fixture("who_am_i_result")
      DynamicsCRM::Model::ExecuteResult.new(file)
    }

    context "parse execute result" do
      it { subject.ResponseName.should == "WhoAmI" }
      it { subject.UserId.should == "1bfa3886-df7e-468c-8435-b5adfb0441ed" }
      it { subject.BusinessUnitId.should == "4e87d619-838a-e311-89a7-6c3be5a80184" }
      it { subject.OrganizationId.should == "0140d597-e270-494a-89e1-bd0b43774e50" }
    end

  end

end
