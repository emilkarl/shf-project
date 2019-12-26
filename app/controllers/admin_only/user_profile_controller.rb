module AdminOnly

  class UserProfileController < ApplicationController

    before_action :authorize_admin
    before_action :get_user

    def become
      return unless current_user.admin?

      new_user = User.find(params[:id])

      bypass_sign_in(new_user)

      current_user = new_user # necessary so feature test passes

      helpers.flash_message(:warn, t('.have_become', user_id: @user.id, user_name: @user.full_name) )

      redirect_to user_path(params[:id])
    end

    def edit
    end

    def update

      # The admin must enter the (admin's) current password to make changes to a User's Profile
      user_params = params[:user]
      current_password = user_params.delete(:current_password)
      update_successful = if @current_user.valid_password?(current_password)
        @user.update(get_params)
      else
        @user.update(get_params)
        @user.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
        false
      end

      if update_successful
        helpers.flash_message(:notice, t('.success'))
      else
        helpers.flash_message(:alert, t('.error'))
      end

      render :edit
    end

    private

    def authorize_admin
      authorize AdminOnly::UserProfile
    end

    def get_user
      @user = User.find(params[:id])
    end

    def get_params
      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end

      # if membership_number is blank then set to nil.
      # The User model allows for blank membership_number.
      # However, the DB (PG) has a unique constraint on this attribute and
      # hence will raise an exception if the attribute is an empty string
      # (one of which will already exist in the DB).
      # Since that exception occurs after model validation, the "update" method
      # cannot rescue this exception. (the DB considers "NULL" values unequal,
      # so "nil" will not trigger the exception on save.)

      if params[:user][:membership_number].blank?
        params[:user][:membership_number] = nil
      end

      params.require(:user).permit(:first_name, :last_name, :email,
                                   :password, :password_confirmation,
                                   :current_password,
                                   :membership_number,
                                   :member_photo,
                                   shf_application_attributes: [ :contact_email, :id ])
    end
  end
end
