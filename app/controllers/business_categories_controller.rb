class BusinessCategoriesController < ApplicationController
  before_action :set_business_category, only: [:show, :edit, :update, :destroy,
                                               :get_edit_row, :get_display_row]

  include RobotsMetaTagShowActionOnly

  before_action :authorize_business_category, only: [:update, :show, :edit, :destroy]


  def index
    authorize BusinessCategory
    @business_categories = BusinessCategory.order(:name)
  end


  def show
    @companies = @business_category.companies.includes(:addresses).order(:name)
    @companies = @companies.searchable unless current_user.admin?
  end


  def new
    authorize BusinessCategory
    @business_category = BusinessCategory.new

    respond_to do |format|
      format.html
      format.js do
        context = params[:parent_cat_id] ? 'subcategory' : 'category'

        new_row = render_to_string(partial: 'category_edit_row',
                                   locals: { business_category: @business_category,
                                             parent_cat_id: params[:parent_cat_id],
                                             record_type: 'new_category',
                                             context: context })
        render json: { new_row: new_row, context: context }
      end
    end
  end


  def edit
  end


  def create
    authorize BusinessCategory
    @business_category = BusinessCategory.new(business_category_params)

    context = params[:parent_cat_id].present? ? 'subcategory' : 'category'

    @business_category.parent_id = params[:parent_cat_id] if context == 'subcategory'

    saved = @business_category.save
    respond_to do |format|
      format.html do
        if saved
          redirect_to @business_category, notice: t('.success')
        else
          render :new
        end
      end

      format.js do
        if saved
          if context == 'category'
            category_id =  @business_category.id
            display_row = render_to_string(partial: 'category_display_row',
                                           locals: { context: context,
                                                     parent_cat_id: params[:parent_cat_id],
                                                     business_category: @business_category })
          else
            category_id =  @business_category.parent_id
            display_row = render_to_string(partial: 'subcategories_display_row',
                                           locals: { context: context,
                                                     business_category: @business_category.parent })
          end

          render json: { business_category_id: category_id,
                         display_row: display_row,
                         context: context,
                         status: 200 }
        else
          render json: { errors: helpers.model_errors_helper(@business_category),
                         status: 422 }
        end
      end
    end
  end

  def get_edit_row
    context = @business_category.root? ? 'category' : 'subcategory'

    edit_row = render_to_string(partial: 'category_edit_row',
                                locals: { business_category: @business_category,
                                          parent_cat_id: params[:parent_cat_id],
                                          record_type: 'existing_category',
                                          context: context })

    respond_to do |format|
      format.js do
        render json: { business_category_id: @business_category.id,
                       edit_row: edit_row }
      end
    end
  end

  def get_display_row
    context = @business_category.root? ? 'category' : 'subcategory'

    display_row = render_to_string(partial: 'category_display_row',
                                   locals: { business_category: @business_category,
                                             parent_cat_id: params[:parent_cat_id],
                                             context: context })

    respond_to do |format|
      format.js do
        render json: { business_category_id: @business_category.id,
                       display_row: display_row }
      end
    end
  end


  def update
    saved = @business_category.update_attributes(business_category_params) # @todo why is 'update_attributes' used?

    respond_to do |format|
      format.html do
        if saved
          redirect_to @business_category, notice: t('.success')
        else
          render :edit
        end
      end

      format.js do
        if saved
          if params[:parent_cat_id].present?
            context = 'subcategory'
            parent_cat_id = @business_category.id
          else
            context = 'category'
            parent_cat_id = nil
          end

          display_row = render_to_string(partial: 'category_display_row',
                                         locals: { business_category: @business_category,
                                                   parent_cat_id: parent_cat_id,
                                                   context: context })

          render json: { business_category_id: @business_category.id,
                         display_row: display_row,
                         status: :ok }
        else
          render json: { errors: helpers.model_errors_helper(@business_category),
                         status: :unprocessable_entity }

        end
      end
    end
  end


  def destroy
    @business_category.destroy

    respond_to do |format|
      format.html { redirect_to business_categories_url, notice: t('.success') }
      format.js { render json: { status: :ok } }
    end

  rescue ActiveRecord::RecordNotFound
    format.html { redirect_to business_categories_url, notice: t('errors.something_wrong') }
    format.js { render json: { status: :not_found } }
  rescue
    format.html { redirect_to business_categories_url, notice: t('errors.something_wrong') }
    format.js { render json: { status: :internal_server_error } }
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_business_category
    @business_category = BusinessCategory.find(params[:id])
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def business_category_params
    params.require(:business_category).permit(:name, :description, :apply_qs_url)
  end


  def authorize_business_category
    authorize @business_category
  end
end
