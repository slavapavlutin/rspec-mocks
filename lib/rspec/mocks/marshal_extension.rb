module RSpec
  module Mocks
    # Support for `patch_marshal_to_support_partial_doubles!` configuration.
    #
    # @private
    class MarshalExtension
      def self.patch!
        return if Marshal.respond_to?(:dump_with_mocks)

        Marshal.instance_eval do
          class << self
            def dump_with_mocks(object, *rest)
              if !::RSpec::Mocks.space.registered?(object) || NilClass === object
                dump_without_mocks(object, *rest)
              else
                dump_without_mocks(object.dup, *rest)
              end
            end

            alias_method :dump_without_mocks, :dump
            undef_method :dump
            alias_method :dump, :dump_with_mocks
          end
        end
      end

      def self.unpatch!
        return unless Marshal.respond_to?(:dump_with_mocks)

        Marshal.instance_eval do
          class << self
            undef_method :dump_with_mocks
            undef_method :dump
            alias_method :dump, :dump_without_mocks
            undef_method :dump_without_mocks
          end
        end
      end
    end
  end
end
