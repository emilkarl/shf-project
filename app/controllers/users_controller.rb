class UsersController < ApplicationController
  include PaginationUtility
  include ImagesUtility

  LOG_FILE = LogfileNamer.name_for('users')

  before_action :set_user, except: [:index, :toggle_membership_package_sent]
  before_action :set_app_config, only: [:show, :proof_of_membership, :update]
  before_action :authorize_user, only: [:show]
  before_action :allow_iframe_request, only: [:proof_of_membership]

  def show
  end

  def proof_of_membership
    image_html = image_html('proof_of_membership', @app_configuration, @user)
    if params[:render_to] == 'jpg'
      download_image('proof_of_membership', 260, image_html)
    else
      show_image(image_html)
    end
  end

  def index
    authorize User
    self.params = fix_FB_changed_q_params(self.params)

    action_params, @items_count, items_per_page = process_pagination_params('user')

    if action_params then
      @filter_are_members = action_params[:membership_filter] == '1'
      @filter_are_not_members = action_params[:membership_filter] == '2'
    end
    @filter_ignore_membership = !(@filter_are_members || @filter_are_not_members)

    membership_filter = 'member = true' if @filter_are_members
    membership_filter = 'member = false' if @filter_are_not_members

    @q = User.ransack(action_params)

    @users = @q.result.includes(:shf_application).where(membership_filter).page(params[:page]).per_page(items_per_page)

    render partial: 'users_list', locals: { q: @q, users: @users, items_count: @items_count } if request.xhr?

  end


  def update
    if @user.update(user_params)
      redirect_to @user, notice: t('.success')
    else
      helpers.flash_message(:alert, t('.error'))

      @user.errors.full_messages.each { |err_message| helpers.flash_message(:alert, err_message) }

      render :show
    end
  end


  # Change the membership status
  def edit_status
    raise 'Unsupported request' unless request.xhr?
    authorize User

    payment = @user.most_recent_membership_payment

    # Note: If there are not any payments (payment is nil),
    # but the status has been changed (ex: admin changes status from 'not a member' to is a member),
    # this will not update the information.
    @user.update!(user_params) && (payment ?
                                       payment.update!(payment_params) : true)

    render partial: 'membership_term_status', locals: { user: @user }

  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
    render partial: 'membership_term_status',
           locals: { user: @user, error: t('users.update.error') }
  end


  # Toggle whether or not a membership package was sent to a user.
  #
  # Just return a success or fail with error message.  Don't
  # render a new page.  Just update info as needed and send
  # 'success' or 'fail' info back.
  def toggle_membership_package_sent

    authorize User

    user =  User.find_by_id(params[:user_id])
    if user
      user.toggle_membership_packet_status

      respond_to do |format|
        format.json { head :ok }
      end

    else
      raise ActiveRecord::RecordNotFound,  "User not found! user_id = #{params[:user_id]}"
    end

  end


  def destroy
    @user.destroy

    ActivityLogger.open(LOG_FILE, 'Manage Users', 'Delete') do |log|
      log.record('info', "User #{@user.id}, #{@user.full_name} (#{@user.email})")
    end

    redirect_back(fallback_location: users_path, notice: t('.success'))
  end



  private

  def authorize_user
    authorize @user
  end


  def set_user
    @user = User.find_by_id(params[:id]) || Visitor.new
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:name, :email, :member, :password,
                                 :password_confirmation,
                                 :date_membership_packet_sent)
  end


  def payment_params
    params.require(:payment).permit(:expire_date, :notes)
  end

end
