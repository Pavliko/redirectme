class GroupsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_group, only: [:show, :edit, :update, :destroy]
  before_filter -> { redirect_to new_group_path }, only: :index, if: -> { current_user.groups.empty? }

  # GET /groups
  def index
    @groups = current_user.groups
  end

  # GET /groups/1
  def show
    render 'edit'
  end

  # GET /groups/new
  def new
    @group = current_user.groups.new(domain: request.host_with_port)
    render 'edit'
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  def create
    @group = current_user.groups.new(group_params)

    if @group.save
      redirect_to groups_path, notice: 'Group was successfully created.'
    else
      frender action: 'edit'
    end
  end

  # PATCH/PUT /groups/1
  def update
    if @group.update(group_params)
      redirect_to groups_path, notice: 'Group was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /groups/1
  def destroy
    @group.destroy
    redirect_to groups_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = current_user.groups.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit(:name, :domain, :category, :subdomain, rules_attributes: [:id, :url, :expression])
    end
end
