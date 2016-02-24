require 'spec_helper'

describe DynamicsCRM::Response::RetrieveResult do

  describe 'initialization' do
    subject {
      file = fixture("retrieve_account_all_columns")
      DynamicsCRM::Response::RetrieveResult.new(file)
    }

    context "parse attributes according to their type" do

      it { expect(subject.id).to eq("93f0325c-a592-e311-b7f3-6c3be5a8a0c8") }
      it { expect(subject.type).to eq("account") }
      it { expect(subject.exchangerate).to eq(1.0) }    # decimal
      it { expect(subject.modifiedon).to be_a(Time) }  # datetime
      it { expect(subject.territorycode).to  eq(1)}     # OptionType
      it { expect(subject.importsequencenumber).to  eq(1)}     # int
      it { expect(subject.donotemail).to eq(false)}     # boolean
      it { expect(subject.revenue).to eq(60000.00) }    # Money
      it { expect(subject.modifiedby).to eq({
            "Id" => "1bfa3886-df7e-468c-8435-b5adfb0441ed",
            "LogicalName" => "systemuser",
            "Name" => "Joe Heth"}) }

      it { expect(subject["id"]).to eq("93f0325c-a592-e311-b7f3-6c3be5a8a0c8") }
      it { expect(subject["type"]).to eq("account") }
    end

    context "parses Attributes list" do
      it { expect(subject.name).to eq("Adventure Works (sample)") }
      it { expect(subject.websiteurl).to eq("http://www.adventure-works.com/") }
      it { expect(subject.address1_city).to eq("Santa Cruz") }

      it { expect(subject["name"]).to eq("Adventure Works (sample)") }
      it { expect(subject["websiteurl"]).to eq("http://www.adventure-works.com/") }
      it { expect(subject["address1_city"]).to eq("Santa Cruz") }
    end

    context "assignment" do
      it "should assign through hash index" do
        expect(subject[:nothing]).to be_nil
        subject[:nothing] = "New Value"
        expect(subject[:nothing]).to eq("New Value")
        expect(subject.nothing).to eq("New Value")
        expect(subject.Nothing).to eq("New Value")
      end
    end

    context "respond to hash methods" do

      it "should has_key?" do
        expect(subject.key?("name")).to be true
        expect(subject.key?("type")).to be true
        expect(subject.key?("nothing")).to be false
      end

      it "should return keys" do
        expect(subject.keys).to include("type", "id", "accountid", "address1_city",
          "address1_stateorprovince", "address1_postalcode", "websiteurl", "name",
          "address1_line1", "address1_country", "address1_composite")
      end
    end

  end

end
