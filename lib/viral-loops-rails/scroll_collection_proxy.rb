module VLoopsRails
  class ScrollCollectionProxy
    include Enumerable

    def initialize(client, opts)
      @client = client
      @scroll_url = opts.delete(:url)
      @limit = opts.delete(:limit)
      @format = opts.delete(:format) || false
      @key_to_extract = opts.delete(:key_to_extract)
      @opts = opts
      @page = 0
    end

    def each
      scroll_params = build_scroll_params
      loop do
        response = @client.send(:request, :get, @scroll_url, scroll_params)
        response = VLoopsRails::Utils.format_response(response, @format, @key_to_extract)

        break unless records_present?(response)

        yield response
        scroll_params = build_scroll_params(response)
      end
      self
    end

    private

    def records_present?(response)
      !response.empty?
    end

    # TODO: make the pagination
    def build_scroll_params(response = nil)
      @page += 1 if response
      @opts[:query_params][:filter] = { skip: @page * @limit, limit: @limit }
      @opts
    end
  end
end
