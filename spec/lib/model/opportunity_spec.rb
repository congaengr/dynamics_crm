require 'spec_helper'

describe DynamicsCRM::Model::Opportunity do

  subject {
    client = DynamicsCRM::Client.new(organization_name: "tinderboxdev")
    DynamicsCRM::Model::Opportunity.new("2dc8d7bb-149f-e311-ba8d-6c3be5a8ad64", client)
  }

  describe '#initialize' do

    context "default instance" do
      it { subject.logical_name.should == "opportunity" }
      it { subject.id.should == "2dc8d7bb-149f-e311-ba8d-6c3be5a8ad64" }
      it { subject.client.should_not be_nil }
    end

  end

  describe '#send_status' do

    context "#set_as_won" do

      it "sets as won" do
        subject.client.stub(:post).and_return(fixture("win_opportunity_response"))
        subject.set_as_won.should == {"ResponseName"=>"WinOpportunity"}
      end
    end

    context "#set_as_lost" do

      it "set as lost" do
        subject.client.stub(:post).and_return(fixture("lose_opportunity_response"))
        subject.set_as_lost.should == {"ResponseName"=>"LoseOpportunity"}
      end
    end
  end

end
