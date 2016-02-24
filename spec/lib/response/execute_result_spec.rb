require 'spec_helper'

describe DynamicsCRM::Response::ExecuteResult do

  describe 'who_am_i' do
    subject {
      file = fixture("who_am_i_result")
      DynamicsCRM::Response::ExecuteResult.new(file)
    }

    context "parse execute result" do
      it { expect(subject.ResponseName).to eq("WhoAmI") }
      it { expect(subject.UserId).to eq("1bfa3886-df7e-468c-8435-b5adfb0441ed") }
      it { expect(subject.BusinessUnitId).to eq("4e87d619-838a-e311-89a7-6c3be5a80184") }
      it { expect(subject.OrganizationId).to eq("0140d597-e270-494a-89e1-bd0b43774e50") }
    end

  end

end
