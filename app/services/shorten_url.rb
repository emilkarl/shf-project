class ShortenUrl

  SHORTEN_URL_LOG = LogfileNamer.name_for(ShortenUrl)
  SUCCESS_CODES = [200, 201, 202].freeze

  def self.short(url)
    response = nil
    response = HTTParty.get("http://tinyurl.com/api-create.php?url=#{url}")
    raise HTTParty::Error if response.match?(/error/i) || !SUCCESS_CODES.include?(response.code)
    response
  rescue HTTParty::UnsupportedURIScheme, HTTParty::UnsupportedFormat, HTTParty::Error => error
    log_error(error, url, response)
    nil
  end

  private_class_method

  def self.log_error(error, url, response)

    ActivityLogger.open(SHORTEN_URL_LOG, 'TINYURL_API', 'shortening url', false) do |log|

      log.error("Exception: #{error.message}")
      log.error("Attempted URL: #{url}")
      if response
        log.error("Response body: #{response.body}")
        log.error("HTTP code: #{response.code}")
      else
        log.error("Exception raised by HTTParty")
      end
    end
  end
end
