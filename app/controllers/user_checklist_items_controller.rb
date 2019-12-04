class UserChecklistItemsController < ApplicationController

  before_action :set_user_checklist_item, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user_checklist_item, only: [:update, :show, :edit, :destroy]


  def index
    authorize UserChecklistItem
    # show all items to an admin else only show items for the current user
    @user_checklist_items = (current_user.admin? ? UserChecklistItem.all : UserChecklistItem.where(user: @current_user))
  end


  def show
  end


  def new
    authorize UserChecklistItem
    @user_checklist_item = UserChecklistItem.new
  end


  def edit
  end


  def create
    @user_checklist_item = UserChecklistItem.new(user_checklist_item_params)

    respond_to do |format|
      if @user_checklist_item.save
        format.html { redirect_to @user_checklist_item, notice: 'User checklist item was successfully created.' }
        format.json { render :show, status: :created, location: @user_checklist_item }
      else
        format.html { render :new }
        format.json { render json: @user_checklist_item.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @user_checklist_item.update(user_checklist_item_params)
        format.html { redirect_to @user_checklist_item, notice: 'User checklist item was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_checklist_item }
      else
        format.html { render :edit }
        format.json { render json: @user_checklist_item.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @user_checklist_item.destroy
    respond_to do |format|
      format.html { redirect_to user_checklist_items_url, notice: 'User checklist item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  private

  def set_user_checklist_item
    @user_checklist_item = UserChecklistItem.find(params[:id])
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def user_checklist_item_params
    params.require(:user_checklist_item).permit(:checklist_item_id, :user_id, :time_completed)
  end


  def authorize_user_checklist_item
    authorize @user_checklist_item
  end

end
