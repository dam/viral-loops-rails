# cf. https://github.com/intercom/intercom-rails/blob/79dd13af210ecd703b90ad008002d1549674da66/lib/intercom-rails/auto_include_filter.rb
# module VLoopsRails
#   module AutoInclude
#     module Method
#       def vloops_rails_auto_include
#         VLoopsRails::AutoInclude::Filter.filter(self)
#       end
#     end

#     class Filter
#       CLOSING_BODY_TAG = %r{</body>}
#       BLACKLISTED_CONTROLLER_NAMES = []

#       def self.filter(controller)
#         return if BLACKLISTED_CONTROLLER_NAMES.include?(controller.class.name)
#         auto_include_filter = new(controller)
#         return unless auto_include_filter.include_javascript?

#         auto_include_filter.include_javascript!
#       end

#       attr_reader :controller

#       def initialize(kontroller)
#         @controller = kontroller
#       end

#       def include_javascript!
#         split = response.body.split('</body>')
#         response.body = split.first + vloops_script_tag.to_s + '</body>'
#         response.body = response.body + split.last if split.size > 1
#       end

#       # TODO
#       def include_javascript?
#         true
#       end

#       private

#       def vloops_script_tag
#         options = { type: :refer_a_friend }
#         @script_tag = ScriptTag.new(options)
#       end
#     end
#   end
# end
