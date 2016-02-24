require 'spec_helper'

describe DynamicsCRM::XML::Money do

  describe '#initialize' do
    let(:value) { 250.0 }
    let(:precision) { 2 }
    subject { DynamicsCRM::XML::Money.new(value, precision) }

    context "with a string" do
      let(:value) { "250.00" }
      it { expect(subject.to_xml).to eq("<a:Value>250.00</a:Value>") }

      context "and precision is 1" do
        let(:precision) { 1 }
        it { expect(subject.to_xml).to eq("<a:Value>250.0</a:Value>") }
      end
    end

    context "with a number" do
      let(:value) { 250 }
      it { expect(subject.to_xml).to eq("<a:Value>250.00</a:Value>") }

      context "and precision is 1" do
        let(:precision) { 1 }
        it { expect(subject.to_xml).to eq("<a:Value>250.0</a:Value>") }
      end
    end

    context "with a float" do
      let(:value) { 250.00 }
      it { expect(subject.to_xml).to eq("<a:Value>250.00</a:Value>") }

      context "and precision is 1" do
        let(:precision) { 1 }
        it { expect(subject.to_xml).to eq("<a:Value>250.0</a:Value>") }
      end
    end

  end
end
