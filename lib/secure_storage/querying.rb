# frozen_string_literal: true

module SecureStorage
  module Querying
    def query_method_define; proc do
      process = proc { |queries| queries.map { |k, v| [secure_name_for(k), encrypt(v)] }.to_h }

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
