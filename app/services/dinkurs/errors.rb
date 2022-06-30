module Dinkurs
  module Errors

    # Dinkurs messages
    INVALID_KEY_MSG = 'Non existent company key'


    class DinkursError < StandardError

      DEFAULT_MSG = 'Unknown Dinkurs Error'

      def initialize(prefix_msg = '', msg = self.class::DEFAULT_MSG)
        prefixed_msg = prefix_msg.blank? ? msg : "#{prefix_msg} : #{msg}"
        super(prefixed_msg)
      end
    end


    class InvalidCompanyKey < DinkursError
      DEFAULT_MSG = "Dinkurs replied with events_data['company'] == #{INVALID_KEY_MSG}"
    end


    class CannotConvertToHash < DinkursError
      DEFAULT_MSG = 'Cannot convert Dinkurs response to a Hash'
    end


    class BadEventInfo < DinkursError
      DEFAULT_MSG = 'Parsing error: Could not get event info from:'

      def initialize(event_info = '', msg = DEFAULT_MSG)
        parsing_error_msg = "#{msg} #{event_info}"
        super('', parsing_error_msg)
      end
    end


    class UnknownError < DinkursError; end

  end
end
