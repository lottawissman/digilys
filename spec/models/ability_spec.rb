require 'spec_helper'

describe Ability do
  let(:user)        { nil }
  subject(:ability) { Ability.new(user) }

  context "User without roles" do
    let(:user)       { create(:user) }
    let(:other_user) { create(:user) }

    it               { should     be_able_to(:update, user) }
    it               { should_not be_able_to(:update, other_user) }

    it               { should     be_able_to(:search, User) }
    it               { should     be_able_to(:search, Evaluation) }

    it               { should     be_able_to(:view,   Student) }
    it               { should     be_able_to(:search, Student) }

    it               { should     be_able_to(:view,   Group) }
    it               { should     be_able_to(:search, Group) }

    it               { should     be_able_to(:index,  Suite) }

    it               { should     be_able_to(:index,  Instance) }

    it               { should     be_able_to(:list,   ColorTable) }

    context "Activity reporting" do
      let(:activity) { create(:activity) }
      let(:other)    { create(:activity) }

      it "allows users to report activites they are assigned to" do
        activity.users << user
        expect(ability).to     be_able_to(:report, activity)
        expect(ability).not_to be_able_to(:report, other)
      end
    end

    context "Instance member" do
      let(:member_of)     { create(:instance) }
      let(:not_member_of) { create(:instance) }

      before(:each) do
        user.add_role :member, member_of
      end

      it { should_not be_able_to(:select, not_member_of) }
      it { should     be_able_to(:select, member_of) }
    end
  end

  context "Admin" do
    let(:user) { create(:admin) }
    it         { should be_able_to(:manage, :all) }
  end

  context "Superuser" do
    let(:user)     { create(:superuser) }

    it { should     be_able_to(:manage,  Student) }
    it { should_not be_able_to(:destroy, Student) }

    it { should     be_able_to(:manage,  Group) }

    it { should_not be_able_to(:manage,  Suite)}
    it { should     be_able_to(:create,  Suite)}
    it { should     be_able_to(:list,    Suite)}

    let(:regular)  { build(:suite, is_template: false) }
    let(:template) { build(:suite, is_template: true) }

    it { should     be_able_to(:view,    template)}
    it { should     be_able_to(:change,  template)}
    it { should_not be_able_to(:destroy, template)}

    it { should_not be_able_to(:view,    regular)}
    it { should_not be_able_to(:change,  regular)}
    it { should_not be_able_to(:destroy, regular)}

    it { should     be_able_to(:manage,  Evaluation) }

    let(:generic_evaluation)  { build(:generic_evaluation) }
    let(:suite_evaluation)    { build(:suite_evaluation) }

    it { should     be_able_to(:view,    generic_evaluation) }
    it { should     be_able_to(:change,  generic_evaluation) }
    it { should     be_able_to(:destroy, generic_evaluation) }

    it { should_not be_able_to(:view,    suite_evaluation) }
    it { should_not be_able_to(:change,  suite_evaluation) }
    it { should_not be_able_to(:destroy, suite_evaluation) }

    it { should     be_able_to(:create,  ColorTable) }
  end

  context "Suite roles" do
    let(:user)  { create(:user) }
    let(:suite) { create(:suite, is_template: false) }
    let(:other) { create(:suite, is_template: false) }

    let(:associations) { [
      build(:participant,       suite: suite),
      build(:suite_evaluation,  suite: suite),
      build(:meeting,           suite: suite),
      build(:activity,          suite: suite)
    ] }
    let(:other_associations) { [
      build(:participant,       suite: other),
      build(:suite_evaluation,  suite: other),
      build(:meeting,           suite: other),
      build(:activity,          suite: other)
    ] }


    it "gives full privileges to their own suites to managers" do
      user.add_role :suite_manager, suite

      expect(ability).to     be_able_to(:view,    suite)
      expect(ability).to     be_able_to(:change,  suite)
      expect(ability).to     be_able_to(:control, suite)

      expect(ability).not_to be_able_to(:view,    other)
      expect(ability).not_to be_able_to(:change,  other)
      expect(ability).not_to be_able_to(:control, other)

      associations.each do |association|
        expect(ability).to     be_able_to(:create,  association)
        expect(ability).to     be_able_to(:view,    association)
        expect(ability).to     be_able_to(:change,  association)
        expect(ability).to     be_able_to(:destroy, association)
      end

      other_associations.each do |association|
        expect(ability).not_to be_able_to(:create,  association)
        expect(ability).not_to be_able_to(:view,    association)
        expect(ability).not_to be_able_to(:change,  association)
        expect(ability).not_to be_able_to(:destroy, association)
      end
    end
    it "gives all but destroy privilieges on their own suites to contributors" do
      user.add_role :suite_contributor, suite

      expect(ability).to     be_able_to(:view,    suite)
      expect(ability).to     be_able_to(:change,  suite)
      expect(ability).not_to be_able_to(:control, suite)

      expect(ability).not_to be_able_to(:view,    other)
      expect(ability).not_to be_able_to(:change,  other)
      expect(ability).not_to be_able_to(:control, other)

      associations.each do |association|
        expect(ability).to be_able_to(:create,  association)
        expect(ability).to be_able_to(:view,    association)
        expect(ability).to be_able_to(:change,  association)
        expect(ability).to be_able_to(:destroy, association)
      end

      other_associations.each do |association|
        expect(ability).not_to be_able_to(:create,  association)
        expect(ability).not_to be_able_to(:view,    association)
        expect(ability).not_to be_able_to(:change,  association)
        expect(ability).not_to be_able_to(:destroy, association)
      end
    end
    it "gives readonly privileges on their own suites to members" do
      user.add_role :suite_member, suite

      expect(ability).to     be_able_to(:view,    suite)
      expect(ability).not_to be_able_to(:change,  suite)
      expect(ability).not_to be_able_to(:control, suite)

      expect(ability).not_to be_able_to(:view,    other)
      expect(ability).not_to be_able_to(:change,  other)
      expect(ability).not_to be_able_to(:control, other)

      associations.each do |association|
        expect(ability).not_to be_able_to(:create,  association)
        expect(ability).to     be_able_to(:view,    association)
        expect(ability).not_to be_able_to(:change,  association)
        expect(ability).not_to be_able_to(:destroy, association)
      end

      other_associations.each do |association|
        expect(ability).not_to be_able_to(:create,  association)
        expect(ability).not_to be_able_to(:view,    association)
        expect(ability).not_to be_able_to(:change,  association)
        expect(ability).not_to be_able_to(:destroy, association)
      end
    end
    it "allows suite members to report results" do
      user.add_role :suite_member, suite
      expect(ability).to be_able_to(:report, build(:suite_evaluation, suite: suite))
    end

    context "for color color table" do
      let(:color_table) { suite.color_table }

      it "gives view and change privileges to the color table" do
        expect(ability).not_to be_able_to(:view, color_table)
        expect(ability).not_to be_able_to(:edit, color_table)

        user.add_role(:suite_member, suite)
        expect(ability).to     be_able_to(:view, color_table)
        expect(ability).not_to be_able_to(:edit, color_table)

        user.add_role(:suite_contributor, suite)
        expect(ability).to     be_able_to(:view, color_table)
        expect(ability).to     be_able_to(:edit, color_table)
      end
    end
  end

  context "Color table" do
    let(:user)              { create(:user) }
    let(:suite_color_table) { create(:suite).color_table }

    it "delegates privileges to the suite" do
      expect(ability).not_to be_able_to(:view, suite_color_table)
      expect(ability).not_to be_able_to(:change, suite_color_table)

      user.add_role(:suite_member, suite_color_table.suite)
      expect(ability).to     be_able_to(:view, suite_color_table)
      expect(ability).not_to be_able_to(:change, suite_color_table)

      user.add_role(:suite_contributor, suite_color_table.suite)
      expect(ability).to     be_able_to(:view, suite_color_table)
      expect(ability).to     be_able_to(:change, suite_color_table)
    end
  end

  context "Table state" do
    let(:user)              { create(:user) }
    let(:suite_color_table) { create(:suite).color_table }
    let(:suite_table_state) { create(:table_state, base: suite_color_table) }

    it "delegates to change privileges on the base" do
      expect(ability).not_to be_able_to(:view,   suite_table_state)
      expect(ability).not_to be_able_to(:change, suite_table_state)

      user.add_role(:suite_member, suite_color_table.suite)
      expect(ability).to     be_able_to(:view,   suite_table_state)
      expect(ability).not_to be_able_to(:change, suite_table_state)

      user.add_role(:suite_contributor, suite_color_table.suite)
      expect(ability).to     be_able_to(:view,   suite_table_state)
      expect(ability).to     be_able_to(:change, suite_table_state)
    end
  end
end
