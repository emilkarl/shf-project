# Format city names, as needed, as described in Address#format_city_name
namespace :shf do
  namespace :one_time do

    desc "Format all city names"
    task format_city_names: :environment do

      log_file = 'log/format_city_names.log'

      ActivityLogger.open(log_file, 'OneTimeRakeTask', 'format_city_names') do |log|

        log.info("Checking #{Address.count} addresses.")

        formatted_count = 0

        Address.order(:city).each do | address |
          city_name = address.city
          formatted_name = address.format_city_name

          if city_name != formatted_name
            
            address.update_column(:city, formatted_name)

            log.info("#{city_name} >> #{formatted_name}")
            formatted_count += 1
          end
        end

        log.info("Formatted #{formatted_count} addresses.")
      end
    end
  end

end
