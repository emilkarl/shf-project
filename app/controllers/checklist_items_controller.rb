class ChecklistItemsController < ApplicationController

  before_action :set_checklist_item, only: [:show, :edit, :update, :destroy]
  before_action :authorize_checklist_item, only: [:update, :show, :edit, :destroy]


  def index
    authorize ChecklistItem
    @checklist_items = ChecklistItem.all.includes(:checklist).order(:checklist_id, :order_in_list)
  end


  def show
  end


  def new
    authorize ChecklistItem
    @checklist_item = ChecklistItem.new
    @all_checklists = get_all_checklists
  end


  def edit
    @all_checklists = get_all_checklists
  end


  def create
    authorize ChecklistItem
    @checklist_item = ChecklistItem.new(checklist_item_params)

    respond_to do |format|
      if @checklist_item.save
        updated_order_in_list = params.dig(:checklist_item, :order_in_list)
        update_checklist_items_order(updated_order_in_list.blank? ? -1 : updated_order_in_list.to_i)

        format.html { redirect_to @checklist_item, notice: 'Checklist item was successfully created.' }
        format.json { render :show, status: :created, location: @checklist_item }
      else
        format.html { render :new }
        format.json { render json: @checklist_item.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @checklist_item.update(checklist_item_params)
        updated_order_in_list = params.dig(:checklist_item, :order_in_list)
        update_checklist_items_order(updated_order_in_list) unless updated_order_in_list.nil?

        format.html { redirect_to @checklist_item, notice: 'Checklist item was successfully updated.' }
        format.json { render :show, status: :ok, location: @checklist_item }
      else
        format.html { render :edit }
        format.json { render json: @checklist_item.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @checklist_item.destroy
    respond_to do |format|
      format.html { redirect_to checklist_items_url, notice: 'Checklist item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  private


  def set_checklist_item
    @checklist_item = ChecklistItem.find(params[:id])
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def checklist_item_params
    params.require(:checklist_item).permit(:name, :description, :date_completed,
                                           :complete, :order_in_list, :checklist_id)
  end


  def authorize_checklist_item
    authorize @checklist_item
  end


  def get_all_checklists
    Checklist.arrange_as_array({ order: 'name' })
  end


  # @param [Integer] order_for_this_item - default is -1, which will insert the item at the end of the list
  def update_checklist_items_order(order_for_this_item = -1)
    @checklist_item.checklist.insert(@checklist_item, order_for_this_item.to_i)
  end
end
