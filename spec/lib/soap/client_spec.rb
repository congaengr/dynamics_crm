require 'spec_helper'

describe Mscrm::Soap::Client do

  describe "#authenticate_ser" do
    let(:endpoint) { "https://login.microsoftonline.com/RST2.srf" }

    it "authenticates with username and password" do

      subject.stub(:post).and_return(fixture("request_security_token_response"))

      subject.authenticate_user('testing', 'password')

      subject.instance_variable_get("@security_token0").should start_with("tMFpDJbJHcZnRVuby5cYmRbCJo2OgOFLEOrUHj+wz")
      subject.instance_variable_get("@security_token1").should start_with("CX7BFgRnW75tE6GiuRICjeVDV+6q4KDMKLyKmKe9A8U")
      subject.instance_variable_get("@key_identifier").should == "D3xjUG3HGaQuKyuGdTWuf6547Lo="
    end

    it "should raise arugment error when no parameters are passed" do
      expect { subject.authenticate_user() }.to raise_error(ArgumentError)
    end
  end

  describe "#retrieve" do
    let(:endpoint) { "https://tinderboxdev.api.crm.dynamics.com/XRMServices/2011/Organization.svc" }

    it "should retrieve object by id" do

      subject.stub(:post).and_return(fixture("retrieve_result"))

      result = subject.retrieve("account", "93f0325c-a592-e311-b7f3-6c3be5a8a0c8")

      result.should be_a(Mscrm::Soap::Model::RetrieveResult)
      result.type.should == "account"
      result.id.should == "93f0325c-a592-e311-b7f3-6c3be5a8a0c8"
      result.name.should == "Adventure Works (sample)"
    end
  end

end
