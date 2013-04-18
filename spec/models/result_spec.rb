require 'spec_helper'

describe Result do
  context "factory" do
    subject { build(:result) }
    it { should be_valid }
  end
  context "accessible attributes" do
    it { should allow_mass_assignment_of(:evaluation_id) }
    it { should allow_mass_assignment_of(:student_id) }
    it { should allow_mass_assignment_of(:value) }
  end
  context "validation" do
    it { should validate_presence_of(:evaluation) }
    it { should validate_presence_of(:student) }
    it { should validate_numericality_of(:value).only_integer }

    context "of the value" do
      let(:evaluation) { build(:evaluation, max_result: rand(100))}
      subject          { build(:result,     evaluation: evaluation) }
      it { should_not allow_value(-1).for(:value) }
      it { should_not allow_value(evaluation.max_result + 1).for(:value) }
      it { should     allow_value(0).for(:value) }
      it { should     allow_value(evaluation.max_result).for(:value) }
    end
  end

  context ".color" do
    let(:evaluation) { create(:evaluation, max_result: 10, red_below: 4, green_above: 7) }

    it "returns red when the value is strictly below the red limit" do
      create(:result, evaluation: evaluation, value: 3).color.should == :red
    end
    it "returns yellow when the value is between the red and green limits" do
      create(:result, evaluation: evaluation, value: 4).color.should == :yellow
      create(:result, evaluation: evaluation, value: 7).color.should == :yellow
    end
    it "returns green when the value is strictly above the green limit" do
      create(:result, evaluation: evaluation, value: 8).color.should == :green
    end
  end
end
