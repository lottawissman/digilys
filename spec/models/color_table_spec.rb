require 'spec_helper'

describe ColorTable do
  context "factory" do
    subject { build(:color_table) }
    it { should be_valid }

    context "invalid" do
      subject { build(:invalid_color_table) }
      it { should_not be_valid }
    end
    context "suite" do
      subject { build(:suite_color_table) }
      it { should be_valid }
    end
  end
  context "accessible attributes" do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:student_data) }
    it { should allow_mass_assignment_of(:instance) }
    it { should allow_mass_assignment_of(:instance_id) }
    it { should allow_mass_assignment_of(:suite) }
    it { should allow_mass_assignment_of(:suite_id) }
  end
  context "validation" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:instance) }

    context "with suite" do
      subject { create(:suite_color_table) }
      it { should_not allow_value(create(:instance)).for(:instance) }
    end
  end

  context "associations" do
    let(:suites)   { create_list(:suite_evaluation,   2) }
    let(:generics) { create_list(:generic_evaluation, 2) }
    subject {
      create(:color_table, evaluations: suites + generics)
    }

    its(:generic_evaluations) { should match_array(generics) }
    its(:suite_evaluations)   { should match_array(suites) }
  end

  describe ".student_data" do
    subject(:color_table) { create(:color_table, student_data: nil) }
    its(:student_data)    { should == [] }

    it "only allows unique entries" do
      color_table.student_data << "foo"
      color_table.student_data << "foo"
      color_table.student_data << "bar"
      color_table.save
      color_table.reload.student_data.should match_array(%w(foo bar))
    end

    context "with existing data" do
      subject(:color_table) { create(:color_table, student_data: %w(foo bar baz)) }
      its(:student_data)    { should == %w(foo bar baz) }

      it "only allows unique entries" do
        color_table.student_data << "foo"
        color_table.save
        color_table.reload.student_data.should match_array(%w(foo bar baz))
      end
    end
  end

  describe "#regular" do
    let!(:regular) { create_list(:color_table,       2) }
    let!(:suite)   { create_list(:suite_color_table, 2) }
    subject        { ColorTable.regular }
    it             { should match_array(regular) }
  end
  describe "#with_suites" do
    let!(:regular) { create_list(:color_table,       2) }
    let!(:suite)   { create_list(:suite_color_table, 2) }
    subject        { ColorTable.with_suites }
    it             { should match_array(suite) }
  end
end
