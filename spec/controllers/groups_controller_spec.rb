require 'spec_helper'

describe GroupsController do
  login_admin

  let(:group) { create(:group) }

  describe "GET #index" do
    let!(:top_level) { create_list(:group, 2) }
    let!(:children)  { create_list(:group, 2, parent: top_level.first) }

    it "lists top level groups" do
      get :index
      response.should be_successful
      assigns(:groups).should match_array(top_level)
    end
  end

  describe "GET #show" do
    it "is successful" do
      get :show, id: group.id
      response.should be_success
    end
  end

  describe "GET #search" do
    let(:grandparent) { create(:group) }
    let(:parent)      { create(:group, parent: grandparent) }
    let(:group)       { create(:group, parent: parent) }

    it "returns the result as json" do
      get :search, q: { name_cont: group.name }

      response.should be_success
      json = JSON.parse(response.body)

      json["more"].should be_false

      json["results"].should have(1).items
      json["results"].first.should include("id"          => group.id)
      json["results"].first.should include("text"        => "#{group.name}, #{parent.name}, #{grandparent.name}")
    end
  end

  describe "GET #new" do
    it "is successful" do
      get :new
      response.should be_success
    end
  end
  describe "POST #create" do
    it "redirects to the group when successful" do
      post :create, group: valid_parameters_for(:group)
      response.should redirect_to(assigns(:group))
    end
    it "renders the new view when validation fails" do
      post :create, group: invalid_parameters_for(:group)
      response.should render_template("new")
    end
  end

  describe "GET #edit" do
    it "is successful" do
      get :edit, id: group.id
      response.should be_success
    end
  end
  describe "PUT #update" do
    it "redirects to the group when successful" do
      new_name = "#{group.name} updated" 
      put :update, id: group.id, group: { name: new_name }
      response.should redirect_to(group)
      group.reload.name.should == new_name
    end
    it "renders the edit view when validation fails" do
      put :update, id: group.id, group: invalid_parameters_for(:group)
      response.should render_template("edit")
    end
  end

  describe "GET #confirm_destroy" do
    it "is successful" do
      get :confirm_destroy, id: group.id
      response.should be_success
    end
  end
  describe "DELETE #destroy" do
    it "redirects to the group list page" do
      delete :destroy, id: group.id
      response.should redirect_to(groups_url())
      Group.exists?(group.id).should be_false
    end
  end

  describe "GET #select_students" do
    it "is successful" do
      get :select_students, id: group.id
      response.should be_success
    end
  end
  describe "PUT #add_students" do
    let(:students) { create_list(:student, 2) }

    it "adds students and redirects back to the group" do
      group.students(true).should be_blank
      put :add_students, id: group.id, group: { students: students.collect(&:id).join(",") }
      response.should redirect_to(group)
      group.students(true).should match_array(students)
    end
  end
  describe "DELETE #remove_students" do
    let(:students) { create_list(:student, 2) }

    it "removes students and redirects back to the group" do
      group.students = students
      delete :remove_students, id: group.id, student_ids: students.collect(&:id)
      response.should redirect_to(group)
      group.students(true).should be_blank
    end
  end

  describe "GET #select_users" do
    it "is successful" do
      get :select_users, id: group.id
      response.should be_success
    end
  end
  describe "PUT #add_users" do
    let(:users) { create_list(:user, 2) }

    it "adds users and redirects back to the group" do
      group.users(true).should be_blank
      put :add_users, id: group.id, group: { users: users.collect(&:id).join(",") }
      response.should redirect_to(group)
      group.users(true).should match_array(users)
    end
  end
  describe "DELETE #remove_users" do
    let(:users) { create_list(:user, 2) }

    it "removes users and redirects back to the group" do
      group.users = users
      delete :remove_users, id: group.id, user_ids: users.collect(&:id)
      response.should redirect_to(group)
      group.users(true).should be_blank
    end
  end
end
