require 'spec_helper'

describe DynamicsCRM::XML::Fault do

  describe 'initialization' do

    context "receiver fault" do
      subject {
        document = REXML::Document.new(fixture('receiver_fault'))
        fault = document.get_elements("//[local-name() = 'Fault']")
        DynamicsCRM::XML::Fault.new(fault)
      }

      context "generate ColumnSet XML" do
        it { subject.code.should == "s:Receiver" }
        it { subject.subcode.should == "a:InternalServiceFault" }
        it { subject.reason.should == "The server was unable to process the request due to an internal error." }
        it { subject.message.should == "#{subject.code}[#{subject.subcode}] #{subject.reason}" }
      end
    end

    context "sender fault" do

      subject {
        document = REXML::Document.new(fixture('sender_fault'))
        fault = document.get_elements("//[local-name() = 'Fault']")
        DynamicsCRM::XML::Fault.new(fault)
      }

      context "generate ColumnSet XML" do
        it { subject.code.should == "s:Sender" }
        it { subject.subcode.should be_nil }
        it { subject.reason.should == "'account' entity doesn't contain attribute with Name = 'ticketsymbol'." }
        it { subject.message.should start_with("#{subject.code}[#{subject.subcode}] #{subject.reason} (Detail =>") }
      end

    end

  end

end
