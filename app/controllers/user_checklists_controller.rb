class UserChecklistsController < ApplicationController

  before_action :set_user_checklist, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user_checklist, only: [:update, :show, :edit, :destroy]
  before_action :authorize_user_checklist_class, only: [:index, :new, :create]


  def index
    found_lists = UserChecklist.find_by(user: current_user)
    @user_checklists = found_lists.blank? ? [] : found_lists
  end


  def show
  end


  def new
    @user_checklist = UserChecklist.new
    @user_checklist.user = current_user
    @all_ordered_list_entries = OrderedListEntry.all_as_array_nested_by_name
  end


  def edit
    @all_ordered_list_entries = OrderedListEntry.all_as_array_nested_by_name
  end


  def create
    @user_checklist = UserChecklist.new(user_checklist_params)

    unless @user_checklist.user.blank? && user_checklist_params.fetch(:user, false)
      @user_checklist.user = current_user
    end


    respond_to do |format|
      if @user_checklist.save
        format.html { redirect_to @user_checklist, notice: 'User checklist was successfully created.' }
        format.json { render :show, status: :created, location: @user_checklist }
      else
        format.html { render :new }
        format.json { render json: @user_checklist.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @user_checklist.update(user_checklist_params)
        format.html { redirect_to @user_checklist, notice: 'User checklist was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_checklist }
      else
        format.html { render :edit }
        format.json { render json: @user_checklist.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @user_checklist.destroy
    respond_to do |format|
      format.html { redirect_to user_checklists_url, notice: 'User checklist was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user_checklist
    @user_checklist = UserChecklist.find(params[:id])
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def user_checklist_params
    params.require(:user_checklist).permit(:user_id, :checklist_id, :date_completed, :checklist)
                                           #user_checklist"=><ActionController::Parameters {"checklist"=>"9", "date_completed(3i)"=>"4", "date_completed(2i)"=>"12", "date_completed(1i)"=>"2019", "date_completed(4i)"=>"22", "date_completed(5i)"=>"19"})

  end


  def authorize_user_checklist
    authorize @user_checklist
  end


  def authorize_user_checklist_class
    authorize UserChecklist
  end


  def all_ordered_list_entries
    @all_ordered_list_entries = OrderedListEntry.all_as_array_nested_by_name
  end

end
