class UserChecklistsController < ApplicationController

  before_action :set_user_checklist, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user_checklist, only: [:update, :show, :edit, :destroy]


  def index
    authorize UserChecklist

    # show all items to an admin else only show items for the current user
    @user_checklists = (current_user.admin? ? UserChecklist.all : UserChecklist.where(user: @current_user))
  end


  def show
  end


  def new
    authorize UserChecklist
    @user_checklist = UserChecklist.new
  end


  def edit
  end


  def create
    @user_checklist = UserChecklist.new(user_checklist_params)

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


  def set_user_checklist
    @user_checklist = UserChecklist.find(params[:id])
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def user_checklist_params
    params.require(:user_checklist).permit(:checklist_id, :user_id)
  end


  def authorize_user_checklist
    authorize @user_checklist
  end

end
