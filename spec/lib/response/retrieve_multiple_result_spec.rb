require 'spec_helper'

describe DynamicsCRM::Response::RetrieveMultipleResult do

  describe 'initialization' do
    subject {
      xml = fixture("retrieve_multiple_result")
      DynamicsCRM::Response::RetrieveMultipleResult.new(xml)
    }

    context "parse attributes according to their type" do

      it { expect(subject.EntityName).to eq("account") }
      it { expect(subject.MinActiveRowVersion).to eq(-1)}
      it { expect(subject.MoreRecords).to eq(false) }
      it { expect(subject.PagingCookie).to include("cookie page=") }
      it { expect(subject.TotalRecordCount).to eq(-1) }
      it { expect(subject.TotalRecordCountLimitExceeded).to eq(false) }
      it { expect(subject.entities.size).to eq(3) }

      it { expect(subject.entities.first.to_hash).to eq({
              :attributes => {"accountid"=>"7bf2e032-ad92-e311-9752-6c3be5a87df0"},
              :entity_state => nil,
              :formatted_values => nil,
              :id => "7bf2e032-ad92-e311-9752-6c3be5a87df0",
              :logical_name => "account",
              :related_entities => nil})
         }

    end

  end

end
