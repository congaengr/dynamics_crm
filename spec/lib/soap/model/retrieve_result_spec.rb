require 'spec_helper'

describe Mscrm::Soap::Model::RetrieveResult do

  describe 'initialization' do
    subject {
      file = File.open(File.dirname(__FILE__) + "/../../../fixtures/retrieve_account_all_columns.xml")
      Mscrm::Soap::Model::RetrieveResult.new(file.read)
    }

    context "parse attributes according to their type" do

      it { subject.id.should == "93f0325c-a592-e311-b7f3-6c3be5a8a0c8" }
      it { subject.type.should == "account" }
      it { subject.exchangerate.should == 1.0 }    # decimal
      it { subject.modifiedon.should be_a(Time) }  # datetime
      it { subject.territorycode.should  == 1}     # OptionType
      it { subject.importsequencenumber.should  == 1}     # int
      it { subject.donotemail.should == false}     # boolean
      it { subject.revenue.should == 60000.00 }    # Money
      it { subject.modifiedby.should == {
            "Id" => "1bfa3886-df7e-468c-8435-b5adfb0441ed",
            "LogicalName" => "systemuser",
            "Name" => "Joe Heth"} }

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
        subject.keys.should include("type", "id", "accountid", "address1_city",
          "address1_stateorprovince", "address1_postalcode", "websiteurl", "name",
          "address1_line1", "address1_country", "address1_composite")
      end
    end

  end

end
