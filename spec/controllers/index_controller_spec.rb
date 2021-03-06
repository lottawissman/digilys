require 'spec_helper'

describe IndexController, versioning: !ENV["debug_versioning"].blank? do
  debug_versioning(ENV["debug_versioning"]) if ENV["debug_versioning"]

  describe "GET #index" do
    login_user

    let(:user)       { logged_in_user }
    let(:other_user) { create(:user) }

    let(:instance)   { create(:instance) }

    let!(:suite)              { create(:suite) }
    let!(:inaccessible_suite) { create(:suite) }
    let!(:closed_suite)       { create(:suite, status: :closed) }
    let!(:instance_suite)     { create(:suite, instance: instance)}

    let!(:overdue_evaluation)                { create(:suite_evaluation, suite: suite,          date: Date.today - 2.days) }
    let!(:upcoming_evaluation)               { create(:suite_evaluation, suite: suite,          date: Date.today + 1.day) }
    let!(:overdue_evaluation_for_user)       { create(:suite_evaluation, suite: suite,          date: Date.today - 2.days) }
    let!(:overdue_evaluation_for_other_user) { create(:suite_evaluation, suite: suite,          date: Date.today - 2.days) }
    let!(:inaccessible_overdue_evaluations)  { create(:suite_evaluation,                        date: Date.today - 2.days) }
    let!(:inaccessible_upcoming_evaluations) { create(:suite_evaluation,                        date: Date.today - 2.days) }
    let!(:instance_evaluation)               { create(:suite_evaluation, suite: instance_suite, date: Date.today - 2.days) }

    let!(:upcoming_meeting)              { create(:meeting, suite: suite,          date: Date.today + 1.day) }
    let!(:overdue_meeting)               { create(:meeting, suite: suite,          date: Date.today - 1.day) }
    let!(:inaccessible_upcoming_meeting) { create(:meeting,                        date: Date.today + 1.day) }
    let!(:inaccessible_overdue_meeting)  { create(:meeting,                        date: Date.today - 1.day) }
    let!(:instance_meeting)              { create(:meeting, suite: instance_suite, date: Date.today + 1.day) }

    let!(:open_activity)     { create(:activity, users: [user], status: :open) }
    let!(:closed_activity)   { create(:activity, users: [user], status: :closed) }
    let!(:instance_activity) { create(:activity, users: [user], status: :open,  suite: instance_suite) }

    before(:each) do
      user.grant       :suite_member, suite
      user.grant       :suite_member, closed_suite
      user.grant       :suite_member, instance_suite
      other_user.grant :suite_member, suite

      overdue_evaluation_for_user.users       << user
      overdue_evaluation_for_other_user.users << other_user
    end

    it "is successful" do
      get :index
      expect(response).to be_success
    end
    it "lists open, accessible suites" do
      get :index
      expect(assigns(:suites)).to eq [suite]
    end
    it "lists upcoming and overdue accessible evaluations" do
      get :index
      expect(assigns(:evaluations)[:overdue]).to  eq [overdue_evaluation, overdue_evaluation_for_user]
      expect(assigns(:evaluations)[:upcoming]).to eq [upcoming_evaluation]
    end
    it "lists upcoming accessible meetings" do
      get :index
      expect(assigns(:meetings)).to eq [upcoming_meeting]
    end
    it "lists the user's open activities" do
      get :index
      expect(assigns(:activities)).to eq [open_activity]
    end
  end
end
