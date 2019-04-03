# frozen_string_literal: true

require 'secure_storage/version'
require 'secure_storage/encryptor'
require 'secure_storage/attribute_define'
require 'secure_storage/querying'

module SecureStorage
  include Encryptor
  include AttributeDefine
  include Querying

  attr_accessor :secure_fields, :secure_storage_key, :prefix, :suffix

  def has_secure *fields
    delegate :encrypt, :decrypt, :secure_name_for, to: self

    self.secure_fields = fields
    fields.each(&attribute_define)
    class_eval(&query_method_define)
  end

  def secure_name_for(attr_name)
    prefix = self.prefix || 'encrypted_'
    suffix = self.suffix || ''
    [prefix, attr_name, suffix].join.to_sym
  end

  def secure_storage
    find_each { |record| secure_fields.each { |attr| record.send(attr) } }
    puts '=== done ==='.green
  end
end

ActiveRecord::Base.extend SecureStorage
