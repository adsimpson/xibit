require "rails/railtie"

module Xibit
  class Railtie < ::Rails::Railtie
    config.serializer = ActiveSupport::OrderedOptions.new
    
    initializer "xibit.set_configs" do |app|
      Xibit::Serializer.class_eval do
        include app.routes.url_helpers
        include app.routes.mounted_helpers   # unless Xibit.rails3_0?
      end
    end
  end
end