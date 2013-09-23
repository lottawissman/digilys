require 'spec_helper'

describe TableStatesController do
  login_user(:admin)

  let(:suite)       { create(:suite) }
  let(:table_state) { create(:table_state, base: suite, data: { foo: "bar" }) }

  describe "GET #show" do
    it "is successful" do
      get :show, id: table_state.id, suite_id: suite.id

      response.should    be_success

      json               = JSON.parse(response.body)
      json["foo"].should == "bar"
    end
  end

  describe "GET #select" do
    it "sets the requested table state as the current user's setting for the suite" do
      get :select, id: table_state.id, suite_id: suite.id
      response.should redirect_to(color_table_suite_url(suite))

      logged_in_user.settings.for(suite).first.data["datatable_state"].should == { "foo" => "bar" }
    end

    context "with existing data" do
      before(:each) do
        logged_in_user.settings.create(customizable: suite, data: { "datatable_state" => { "bar" => "baz" }, "zomg" => "lol" })
      end
      it "overrides the datatable state, and leaves the other data alone" do
        get :select, id: table_state.id, suite_id: suite.id
        response.should redirect_to(color_table_suite_url(suite))

        data = logged_in_user.settings.for(suite).first.data
        data["datatable_state"].should == { "foo" => "bar" }
        data["zomg"].should            == "lol"
      end
    end
  end

  describe "POST #create" do
    it "is successful when valid" do
      post :create, suite_id: suite.id, table_state: valid_parameters_for(:table_state)

      response.should   be_success

      json  = JSON.parse(response.body)
      state = TableState.find(TableState.maximum("id"))

      json["id"].should   == state.id
      json["name"].should == state.name
    end
    it "is returns an error when invalid" do
      post :create, suite_id: suite.id, table_state: invalid_parameters_for(:table_state)

      response.status.should    == 400

      json                      = JSON.parse(response.body)
      json["errors"].should_not be_blank
    end
  end

  describe "PUT #update" do
    it "is successful when valid" do
      new_name = "#{table_state.name} updated"
      put :update, id: table_state.id, suite_id: suite.id, table_state: { name: new_name }

      response.should                be_success

      json                           = JSON.parse(response.body)
      json["id"].should              == table_state.id
      json["name"].should            == new_name
      table_state.reload.name.should == new_name
    end
    it "is returns an error when invalid" do
      put :update, id: table_state.id, suite_id: suite.id, table_state: { name: "" }

      response.status.should    == 400

      json                      = JSON.parse(response.body)
      json["errors"].should_not be_blank
    end
  end

  describe "DELETE #destroy" do
    it "destroys the object" do
      delete :destroy, id: table_state.id, suite_id: suite.id
      response.should be_success
      TableState.where(id: table_state.id).first.should be_nil
    end
  end
end
