module VLoopsRails
  class Railtie < Rails::Railtie
    initializer 'viral-loops-rails' do |_app|
      ActiveSupport.on_load(:action_view) do
        include ScriptTagsHelper
      end
      ActiveSupport.on_load(:action_controller) do
        include AutoInclude::Method
      end
    end
  end
end
