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
        it { expect(subject.code).to eq("s:Receiver") }
        it { expect(subject.subcode).to eq("a:InternalServiceFault") }
        it { expect(subject.reason).to eq("The server was unable to process the request due to an internal error.") }
        it { expect(subject.message).to eq("#{subject.code}[#{subject.subcode}] #{subject.reason}") }
      end
    end

    context "sender fault" do

      subject {
        document = REXML::Document.new(fixture('sender_fault'))
        fault = document.get_elements("//[local-name() = 'Fault']")
        DynamicsCRM::XML::Fault.new(fault)
      }

      context "generate ColumnSet XML" do
        it { expect(subject.code).to eq("s:Sender") }
        it { expect(subject.subcode).to be_nil }
        it { expect(subject.reason).to eq("'account' entity doesn't contain attribute with Name = 'ticketsymbol'.") }
        it { expect(subject.message).to start_with("#{subject.code}[#{subject.subcode}] #{subject.reason} (Detail =>") }
      end

    end

  end

end
