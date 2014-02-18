require 'spec_helper'

describe Mscrm::Soap::Model::RetrieveMultipleResult do

  describe 'initialization' do
    subject {
      xml = fixture("retrieve_multiple_result")
      Mscrm::Soap::Model::RetrieveMultipleResult.new(xml)
    }

    context "parse attributes according to their type" do

      it { subject.EntityName.should == "account" }
      it { subject.MinActiveRowVersion.should == -1}
      it { subject.MoreRecords.should == false }
      it { subject.PagingCookie.should include("cookie page=") }
      it { subject.TotalRecordCount.should == -1 }
      it { subject.TotalRecordCountLimitExceeded.should == false }
      it { subject.entities.size.should == 3 }

      it { subject.entities.first.to_hash.should == {
              :attributes => {"accountid"=>"7bf2e032-ad92-e311-9752-6c3be5a87df0"},
              :entity_state => nil,
              :formatted_values => nil,
              :id => "7bf2e032-ad92-e311-9752-6c3be5a87df0",
              :logical_name => "account",
              :related_entities => nil}
         }

    end

  end

end
