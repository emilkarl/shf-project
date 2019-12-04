class OrderedListEntriesController < ApplicationController

  before_action :set_ordered_list_entry, only: [:show, :edit, :update, :destroy]
  before_action :authorize_ordered_list_entry, only: [:update, :show, :edit, :destroy]
  before_action :authorize_ordered_list_entry_class, only: [:index, :new, :create]


  def index
    authorize_ordered_list_entry_class
    @ordered_list_entries = OrderedListEntry.arrange_as_array(order: ['ancestry', 'list_position', 'name'])
  end


  def show
  end


  def new
    @ordered_list_entry = OrderedListEntry.new
    @all_allowable_parents = all_allowable_parents
  end


  def edit
    @all_allowable_parents = all_allowable_parents
  end


  def create
    @ordered_list_entry = OrderedListEntry.new(ordered_list_entry_params)

    respond_to do |format|
      if @ordered_list_entry.save
        format.html { redirect_to @ordered_list_entry, notice: 'A new OrderedListEntry was successfully created.' }
        format.json { render :show, status: :created, location: @ordered_list_entry }
      else
        format.html { render :new }
        format.json { render json: @ordered_list_entry.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @ordered_list_entry.update(ordered_list_entry_params)
        format.html { redirect_to @ordered_list_entry, notice: 'OrderedListEntry was successfully updated.' }
        format.json { render :show, status: :ok, location: @ordered_list_entry }
      else
        format.html { render :edit }
        format.json { render json: @ordered_list_entry.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @ordered_list_entry.destroy
    respond_to do |format|
      format.html { redirect_to ordered_list_entries_url, notice: 'OrderedListEntry was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  # This returns JSON for an AJAX/xhr request.  It returns the number of children for an OrderedListEntry with a given id.
  #
  # @return [JSON] - JSON: integer - the number of children for an OrderedListEntry.  0 (zero) if there are no children
  def max_list_position
    raise 'Unsupported request' unless request.xhr?
    authorize_ordered_list_entry_class

    ole_id = params[:id] # FIXME - handle if there is no [:id]
    ordered_list_entry = OrderedListEntry.find(ole_id)

    max_position = 0 # default.  This is zero-based and can never be less than zero
    error_text = ''

    if ordered_list_entry
      status = 'ok'
      max_position = ordered_list_entry.children.size - 1 if ordered_list_entry.children?
    else
      status = 'error' # not found
      error_text = t('.not_found', id: ole_id) # FIXME
    end

    render json: { status: status, id: ole_id, max_position: max_position, error_text: error_text }
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_ordered_list_entry
    @ordered_list_entry = OrderedListEntry.find(params[:id])
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def ordered_list_entry_params
    params.require(:ordered_list_entry).permit(:name, :description, :position, :parent_id, :list_position)
  end


  def authorize_ordered_list_entry
    authorize @ordered_list_entry
  end


  def authorize_ordered_list_entry_class
    authorize OrderedListEntry
  end


  # @return [Array[OrderedListItem]] - list of all OrderedListEntries
  #   that could be a parent to @ordered_list_entry;
  #   all OrderedListEntries _except_ @ordered_list_entry; cannot be a parent of itself.
  def all_allowable_parents
    # FIXME must be sorted correctly
    all_ordered_list_entries.reject { |entry| entry.id == @ordered_list_entry.id }
  end


  def all_ordered_list_entries
    OrderedListEntry.arrange_as_array({ order: 'name' })
  end


end
