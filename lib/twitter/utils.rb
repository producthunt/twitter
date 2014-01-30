module Twitter
  module Utils
    class << self
      def included(base)
        base.extend(ClassMethods)
      end
    end

    module ClassMethods
      def deprecate_alias(new_name, old_name, &block)
        define_method(new_name) do |*args|
          warn "#{Kernel.caller.first}: [DEPRECATION] ##{new_name} is deprecated. Use ##{old_name} instead."
          send(old_name, *args, &block)
        end
      end
    end

  private

    def symbolize_keys(object)
      if object.is_a?(Array)
        object.inject([]) do |result, val|
          result << symbolize_keys(val)
          result
        end
      elsif object.is_a?(Hash)
        object.inject({}) do |result, (key, val)|
          new_key = key.respond_to?(:to_sym) ? key.to_sym : key
          result[new_key] = symbolize_keys(val)
          result
        end
      else
        object
      end
    end

    # Returns a new array with the concatenated results of running block once for every element in enumerable.
    # If no block is given, an enumerator is returned instead.
    #
    # @param enumerable [Enumerable]
    # @return [Array, Enumerator]
    def flat_pmap(enumerable)
      return to_enum(:flat_pmap, enumerable) unless block_given?
      pmap(enumerable, &Proc.new).flatten!(1)
    end
    module_function :flat_pmap

    # Returns a new array with the results of running block once for every element in enumerable.
    # If no block is given, an enumerator is returned instead.
    #
    # @param enumerable [Enumerable]
    # @return [Array, Enumerator]
    def pmap(enumerable)
      return to_enum(:pmap, enumerable) unless block_given?
      if enumerable.count == 1
        enumerable.collect { |object| yield(object) }
      else
        enumerable.collect { |object| Thread.new { yield(object) } }.collect(&:value)
      end
    end
    module_function :pmap
  end
end
