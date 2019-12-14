class OrderedListEntriesController < ApplicationController

  before_action :set_ordered_list_entry, only: [:show, :edit, :update, :destroy]
  before_action :authorize_ordered_list_entry, only: [:update, :show, :edit, :destroy]
  before_action :authorize_ordered_list_entry_class, only: [:index, :new, :create]


  def index
    authorize_ordered_list_entry_class
    @ordered_list_entries = OrderedListEntry.all_as_array_nested_by_name
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
    @ordered_list_entry.list_position = corrected_list_position(ordered_list_entry_params) if ordered_list_entry_params.dig('list_position').blank?

    insert_into_parent(ordered_list_entry_params)

    respond_to do |format|
      if @ordered_list_entry.save
        format.html { redirect_to @ordered_list_entry, notice: t('.success', name: @ordered_list_entry.name) }
        format.json { render :show, status: :created, location: @ordered_list_entry }
      else
        format.html { render :new, error: 'Error creating the new OrderedListEntry:  ' } # FIXME show the errors
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
    @ordered_list_entry.destroy # FIXME test to see if it has sublists, is associated with a User, etc.
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
      error_text = t('ordered_list_entries.max_list_position.not_found', id: ole_id) # FIXME
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
  def all_allowable_parents
    # FIXME should be sorted correctly
    @ordered_list_entry.allowable_as_parents(all_ordered_list_entries)
  end


  def all_ordered_list_entries
    #OrderedListEntry.arrange_as_array({ order: 'name' }) # FIXME shouldn't this be all_as_array_nested_by_name
    OrderedListEntry.all_as_array_nested_by_name
  end


  # Set a default list position if none given:
  # if there is a parent list, the default list position is the next position in the list
  # else it is zero
  # TODO - does this belong here or in the OrderedListEntry?  (or perhaps some of this belongs in OrderedListEntry?)
  def corrected_list_position(list_entry_params)
    default_list_position = 0

    if list_entry_params.dig('list_position').blank?

      unless list_entry_params.dig('parent_id').blank?
        parent_list = OrderedListEntry.find(list_entry_params.fetch('parent_id', false).to_i)
        default_list_position = parent_list.next_list_position
      end

    else
      # this is here in case this check is not done when this is called
      default_list_position = list_entry_params.dig('list_position')
    end

    default_list_position
  end


  # Insert this item into a parent is if there is a parent list for this item
  def insert_into_parent(list_entry_params)

    # if a parent list was specified
    unless list_entry_params.fetch('parent_id', nil).blank?
      parent_list = OrderedListEntry.find(ordered_list_entry_params.fetch('parent_id', false).to_i)

      # insert this item in the position specified.  The position of other items may be altered per OrderedListEntry behavior
      parent_list.insert(@ordered_list_entry, @ordered_list_entry.list_position)
    end
  end


end
