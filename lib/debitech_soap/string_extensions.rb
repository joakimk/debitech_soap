module DebitechSoap
  module StringExtensions

    module Underscore
      def underscore
        word = dup
        word.gsub!(/::/, '/')
        word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        word.tr!("-", "_")
        word.downcase!
        word
      end
    end

    module CamelCase
      def camelcase(first_letter_in_uppercase = true)
        if first_letter_in_uppercase
          self.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
        else
          self.to_s[0].chr.downcase + camelize(lower_case_and_underscored_word)[1..1]
        end
      end
    end

  end
end

unless String.methods.include?('underscore')
  String.class_eval do
    include DebitechSoap::StringExtensions::Underscore
  end
end

unless String.methods.include?('camelcase')
  String.class_eval do
    include DebitechSoap::StringExtensions::CamelCase
  end
end
