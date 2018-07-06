module VLoopsRails
  SCRIPT_TAG_HELPER_CALLED_INSTANCE_VARIABLE = :@_vloops_script_tag_helper_called

  module ScriptTagsHelper
    def vloops_script_tag(options = {})
      if defined?(controller)
        controller.instance_variable_set(SCRIPT_TAG_HELPER_CALLED_INSTANCE_VARIABLE, true)
      end

      ReferAFriendWidget.new(options) if options[:type] == :refer_a_friend
    end
  end
end
