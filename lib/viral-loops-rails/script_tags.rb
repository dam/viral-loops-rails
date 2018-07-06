# cf. https://intercom.help/viral-loops/refer-a-friend/installation-instructions/refer-a-friend-html
module VLoopsRails
  class ReferAFriendWidget
    def initialize(options = {})
      @campaign_id = VLoopsRails.config[:campaign_id]
      @position = options[:position] || 'bottom-right'

      validate_settings!
    end

    def to_s
      str = "<script>#{vloops_javascript}</script>\n"
      str.respond_to?(:html_safe) ? str.html_safe : str
    end

    private

    def validate_settings!
      raise(MisconfiguredWidget, 'A campaign id is mandatory') unless @campaign_id
    end

    def vloops_javascript
      <<-JS
!function(){var a=window.VL=window.VL||{};return a.instances=a.instances||{},a.invoked?void(window.console&&console.error&&console.error("VL snippet loaded twice.")):(a.invoked=!0,void(a.load=function(b,c,d){var e={};e.publicToken=b,e.config=c||{};var f=document.createElement("script");f.type="text/javascript",f.id="vrlps-js",f.defer=!0,f.src="https://app.viral-loops.com/client/vl/vl.min.js";var g=document.getElementsByTagName("script")[0];return g.parentNode.insertBefore(f,g),f.onload=function(){a.setup(e),a.instances[b]=e},e.identify=e.identify||function(a,b){e.afterLoad={identify:{userData:a,cb:b}}},e.pendingEvents=[],e.track=e.track||function(a,b){e.pendingEvents.push({event:a,cb:b})},e.pendingHooks=[],e.addHook=e.addHook||function(a,b){e.pendingHooks.push({name:a,cb:b})},e.$=e.$||function(a){e.pendingHooks.push({name:"ready",cb:a})},e}))}();var campaign=VL.load("#{@campaign_id}",{autoLoadWidgets:!0});campaign.addHook("boot",function(){campaign.widgets.create("rewardingWidget",{container:"body",position:"#{@position}"}),campaign.widgets.create("rewardingWidgetTrigger",{container:"body",position:"#{@position}"})});
JS
    end
  end
end
