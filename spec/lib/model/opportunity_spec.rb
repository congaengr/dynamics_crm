require 'spec_helper'

describe DynamicsCRM::Model::Opportunity do

  subject {
    client = DynamicsCRM::Client.new(organization_name: "tinderboxdev")
    DynamicsCRM::Model::Opportunity.new("2dc8d7bb-149f-e311-ba8d-6c3be5a8ad64", client)
  }

  describe '#initialize' do

    context "default instance" do
      it { expect(subject.logical_name).to eq("opportunity") }
      it { expect(subject.id).to eq("2dc8d7bb-149f-e311-ba8d-6c3be5a8ad64") }
      it { expect(subject.client).not_to be_nil }
    end

  end

  describe '#send_status' do

    context "#set_as_won" do

      it "sets as won" do
        allow(subject.client).to receive(:post).and_return(fixture("win_opportunity_response"))
        expect(subject.set_as_won).to eq({"ResponseName"=>"WinOpportunity"})
      end
    end

    context "#set_as_lost" do

      it "set as lost" do
        allow(subject.client).to receive(:post).and_return(fixture("lose_opportunity_response"))
        expect(subject.set_as_lost).to eq({"ResponseName"=>"LoseOpportunity"})
      end
    end
  end

end
