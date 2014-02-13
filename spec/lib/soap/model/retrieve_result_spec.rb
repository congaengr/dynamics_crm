require 'spec_helper'

describe Mscrm::Soap::Model::RetrieveResult do

  describe 'initialization' do
    subject {
      file = File.open(File.dirname(__FILE__) + "/../../../fixtures/retrieve_result.xml")
      Mscrm::Soap::Model::RetrieveResult.new(file.read)
    }

    context "parses Id and LogicalName" do

      it { subject.id.should == "93f0325c-a592-e311-b7f3-6c3be5a8a0c8" }
      it { subject.type.should == "account" }

      it { subject["id"].should == "93f0325c-a592-e311-b7f3-6c3be5a8a0c8" }
      it { subject["type"].should == "account" }
    end

    context "parses Attributes list" do
      it { subject.name.should == "Adventure Works (sample)" }
      it { subject.websiteurl.should == "http://www.adventure-works.com/" }
      it { subject.address1_city.should == "Santa Cruz" }

      it { subject["name"].should == "Adventure Works (sample)" }
      it { subject["websiteurl"].should == "http://www.adventure-works.com/" }
      it { subject["address1_city"].should == "Santa Cruz" }
    end

    context "assignment" do
      it "should assign through hash index" do
        subject[:nothing].should be_nil
        subject[:nothing] = "New Value"
        subject[:nothing].should == "New Value"
        subject.nothing.should == "New Value"
        subject.Nothing.should == "New Value"
      end
    end

    context "respond to hash methods" do

      it "should has_key?" do
        subject.has_key?("name").should be_true
        subject.has_key?("type").should be_true
        subject.has_key?("nothing").should be_false
      end

      it "should return keys" do
        subject.keys.should == ["type", "id", "accountid", "address1_city", "address1_stateorprovince", "address1_postalcode", "websiteurl", "name", "address1_line1", "address1_country", "address1_composite"]
      end
    end

  end

end
