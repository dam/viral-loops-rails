# cf. https://github.com/intercom/intercom-rails/blob/79dd13af210ecd703b90ad008002d1549674da66/lib/intercom-rails/auto_include_filter.rb
module VLoopsRails
  module AutoInclude
    module Method
      def vloops_rails_auto_include(options = {})
        VLoopsRails::AutoInclude::Filter.filter(self, options)
      end
    end

    class Filter
      CLOSING_BODY_TAG = %r{</body>}
      BLACKLISTED_CONTROLLER_NAMES = []

      def self.filter(controller, options)
        return if BLACKLISTED_CONTROLLER_NAMES.include?(controller.class.name)
        auto_include_filter = new(controller, options)
        return unless auto_include_filter.include_javascript?

        auto_include_filter.include_javascript!
      end

      attr_reader :controller

      def initialize(kontroller, options)
        @controller = kontroller
        @script_tag = vloops_script_tag(options)
      end

      def include_javascript!
        split = response.body.split('</body>')
        response.body = split.first + @script_tag.to_s + '</body>'
        response.body = response.body + split.last if split.size > 1
      end

      def include_javascript?
        html_content_type? &&
          response_has_closing_body_tag? &&
          !intercom_script_tag_called_manually?
      end

      private

      def response
        controller.response
      end

      def html_content_type?
        response.content_type == 'text/html'
      end

      def response_has_closing_body_tag?
        !!(response.body[CLOSING_BODY_TAG])
      end

      def intercom_script_tag_called_manually?
        controller.instance_variable_get(SCRIPT_TAG_HELPER_CALLED_INSTANCE_VARIABLE)
      end

      def vloops_script_tag(options)
        ReferAFriendWidget.new(options) if options[:type] == :refer_a_friend
      end
    end
  end
end
