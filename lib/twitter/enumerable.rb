module Twitter
  module Enumerable
    include ::Enumerable

    # @return [Enumerator]
    def each(start = 0)
      return to_enum(:each, start) unless block_given?
      Array(@collection[start..-1]).each do |element|
        yield(element)
      end
      unless last?
        start = [@collection.size, start].max
        fetch_next_page
        each(start, &Proc.new)
      end
      self
    end

    # Note(Mike Coutermarsh): allows us to work with entire collection of results rather than 1 at a time
    #   Also, exposes the cursor in the block, so that we can stop ourselves from ever hitting the limit.
    def each_page_with_cursor(start = 0)
      yield(Array(@collection[start..-1]), self)

      unless last?
        start = [@collection.size, start].max
        fetch_next_page
        each_page_with_cursor(start, &Proc.new)
      end
      self
    end

  private

    # @return [Boolean]
    def last?
      true
    end
  end
end
