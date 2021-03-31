class UsersController < ApplicationController

  include RobotsMetaTagShowActionOnly
  include SetAppConfiguration
  include PaginationUtility
  include ImagesUtility

  LOG_FILE = LogfileNamer.name_for('users')

  before_action :set_user, except: [:index, :toggle_membership_package_sent]
  before_action :set_app_config, only: [:show, :proof_of_membership, :update, :edit_status]
  before_action :authorize_user, only: [:show]
  before_action :allow_iframe_request, only: [:proof_of_membership]

  #================================================================================

  def show
  end

  def proof_of_membership
    render_as = request.format.to_sym

    if render_as == :jpg
      jpg_image = @user.proof_of_membership_jpg

      unless jpg_image
        jpg_image = create_image_jpg('proof_of_membership', 260, @app_configuration, @user)
        @user.proof_of_membership_jpg = jpg_image
      end

      download_image('proof_of_membership', jpg_image, send_as(params[:context]))
    else
      image_html = image_html('proof_of_membership', @app_configuration,
                              @user, render_as, params[:context])
      show_image(image_html)
    end
  end

  def index
    authorize User
    self.params = fix_FB_changed_q_params(self.params)

    action_params, @items_count, items_per_page = process_pagination_params('user')

    if action_params
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


  # Manually change the membership status
  #   Currently this just changes the date on a Payment.
  #
  # FIXME - What should happen when a User's actual membership status is changed (no longer just a payment date change)?
  #   If this is manually set, will it be 'undone' when the MembershipStatusUpdater checks things and tries to logically update?
  #   Should we have a 'lock status' flag?
  def edit_status
    raise 'Unsupported request' unless request.xhr?
    authorize User

    payment = @user.most_recent_membership_payment

    # Note: If there are not any payments (payment is nil),
    # but the status has been changed (ex: admin changes status from 'not a member' to is a member),
    # this will not update the information.
    @user.update!(user_params) && (payment ?
                                       payment.update!(payment_params) : true)

    if @user.member?
      render partial: 'show_for_member', locals: { user: @user, current_user: @current_user, app_config: @app_configuration }
    else
      render partial: 'show_for_applicant', locals: { user: @user, current_user: @current_user }
    end


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

  # Set @user to @current_user for situations where the current user
  # is the one viewing and requesting the controller actions.
  def set_user_to_current_user
    @user = @current_user
  end

end
