class Xibit::Serializer
  module UrlMethods
    extend ActiveSupport::Concern
    
    # INSTANCE METHODS
    
    def default_url_options
      Rails.application.config.serializer.default_url_options or {}
    end
  end
end