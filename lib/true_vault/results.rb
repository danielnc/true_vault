module TrueVault
  class Results
    include Enumerable
    extend Forwardable

    def_delegators :results, :each, :any?, :empty?, :size, :length, :slice, :[], :to_ary
    attr_reader :klazz, :response
    def initialize(klazz, response)
      @klazz = klazz
      @response = response
    end

    def results
      @results ||= begin
        # UGLY HACK REMOVE PLZ PLZ PLZ PLZ
        response.data.documents[0..(per_page - 1).map do |document_id|
          klazz.find_by_true_vault_document_id(document_id)
        end.compact
      end
    end

    def total_count
      response.data.info.total_result_count
    end
    alias_method :total_entries, :total_count

    def current_page
      response.data.info.current_page
    end

    def per_page
      response.data.info.per_page
    end
    alias_method :limit_value, :per_page

    def total_pages
      (total_count / per_page.to_f).ceil
    end
    alias_method :num_pages, :total_pages

    def previous_page
      current_page > 1 ? (current_page - 1) : nil
    end

    def next_page
      current_page < total_pages ? (current_page + 1) : nil
    end

    def first_page?
      previous_page.nil?
    end

    def last_page?
      next_page.nil?
    end
  end
end