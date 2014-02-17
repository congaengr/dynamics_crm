require 'spec_helper'

describe Mscrm::Soap::Model::Fault do

  describe 'initialization' do
    subject {
      document = REXML::Document.new(fixture('fault'))
      fault = document.get_elements("//[local-name() = 'Fault']")
      Mscrm::Soap::Model::Fault.new(fault)
    }

    context "generate ColumnSet XML" do
      it { subject.code.should == "s:Receiver" }
      it { subject.subcode.should == "a:InternalServiceFault" }
      it { subject.reason.should == "The server was unable to process the request due to an internal error." }
      it { subject.message.should == "#{subject.code}[#{subject.subcode}] #{subject.reason}" }
    end

  end

end
