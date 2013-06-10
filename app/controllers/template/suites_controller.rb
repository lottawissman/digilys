class Template::SuitesController < ApplicationController
  load_and_authorize_resource

  def index
    @suites = @suites.template.order(:name).page(params[:page])
  end

  def search
    @suites        = @suites.template.order(:name).search(params[:q]).result.page(params[:page])
    json           = {}
    json[:results] = @suites.collect { |s| { id: s.id, text: s.name } }
    json[:more]    = !@suites.last_page?

    render json: json.to_json
  end

  def new
    @suite.is_template = true
    render template: "suites/new"
  end
end
