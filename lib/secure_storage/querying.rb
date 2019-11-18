# frozen_string_literal: true

module SecureStorage
  module Querying
    def query_method_define; proc do
      process = proc do |queries|
        queries.map do |k, v|
          if v.is_a?(Array)
            [secure_name_for(k), v.map(&method(:encrypt))]
          else
            [secure_name_for(k), encrypt(v)]
          end
        end.to_h
      end

      scope :with_encrypted, -> (queries) { where(process.(queries)) }

      scope :xwhere, -> (queries) do
        with_encrypted(queries.slice(*secure_fields))
            .where(queries.except(*secure_fields))
      end

      define_singleton_method :xfind_by do |queries|
        find_by(**process.(queries.slice(*secure_fields)),
                **queries.except(*secure_fields))
      end

      define_singleton_method :xfind_by! do |queries|
        find_by!(**process.(queries.slice(*secure_fields)),
                **queries.except(*secure_fields))
      end

      define_singleton_method :xfind_or_initialize_by do |queries|
        find_or_initialize_by(
            **process.(queries.slice(*secure_fields)),
            **queries.except(*secure_fields))
      end
    end end
  end
end
