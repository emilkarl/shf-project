module AdminOnly

  class AppConfigurationController < ApplicationController

    before_action :authorize_admin
    before_action :get_app_configuration


    def show
    end


    def edit
    end


    def update
      if @app_configuration.update(app_config_params)
        redirect_to @app_configuration, notice: t('.success')
      else
        helpers.flash_message(:alert, "#{t('.error')}: #{@app_configuration.errors.full_messages.join(', ')}")
        render :edit
      end
    end


    # =====================================================================


    private


    def authorize_admin
      authorize AdminOnly::AppConfiguration
    end


    def get_app_configuration
      @app_configuration = AppConfiguration.instance
    end


    def app_config_params
      params.require(:admin_only_app_configuration)
          .permit(:chair_signature, :shf_logo, :h_brand_logo, :sweden_dog_trainers,
                  :email_admin_new_app_received_enabled,
                  :site_name,
                  :site_meta_title, :site_meta_description, :site_meta_keywords,
                  :og_type,
                  :twitter_card_type,
                  :facebook_app_id,
                  :site_meta_image,
                  :payment_too_soon_days)
    end
  end

end
