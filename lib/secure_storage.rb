require 'secure_storage/version'

module SecureStorage
  def has_secure *fields
    @secure_storage = fields

    class_exec(fields) do |fields|
      fields.each do |field|
        # TODO: type convert (can set to int)
        # TODO: How do I know if it is encrypted? (last char is `=`?)
        define_method field do
          data = super()
          begin
            SecureStorage.decrypt(data)
          rescue # TODO
            update!(field => SecureStorage.encrypt(data))
            data
          end
        end
      end

      before_save do
        fields.each do |field|
          next if changes[field].nil?
          begin
            SecureStorage.decrypt(send(field))
          rescue # TODO
            send("#{field}=", SecureStorage.encrypt(send(field)))
          end
        end
      end

      define_singleton_method :where do |*args|
        return super() if args.blank?
        fields.each do |field|
          next unless args.first.key?(field)
          args.first[field] = SecureStorage.encrypt(args.first[field])
        end if args.first.is_a?(Hash)
        super(*args)
      end

      define_singleton_method :find_by do |hash|
        if (keys = fields & hash.keys).present?
          keys.each { |key| hash[key] = SecureStorage.encrypt(hash[key]) }
        end
        super(hash)
      end

      define_singleton_method "find_by_#{field}" do |value|
        super(SecureStorage.encrypt(value))
      end
    end
  end

  def secure_storage
    all
    true
  end

  def encrypt(data)
    return if data.blank?
    cipher = OpenSSL::Cipher::AES256.new(:CBC)
    cipher.encrypt
    cipher.key = symmetric_key
    data = cipher.update(data) << cipher.final
    Base64.strict_encode64(data)
  end

  def decrypt(data)
    return if data.blank?
    cipher = OpenSSL::Cipher::AES256.new(:CBC)
    cipher.decrypt
    cipher.key = symmetric_key
    data = cipher.update(Base64.strict_decode64(data)) << cipher.final
    data.force_encoding('utf-8')
  end

  # TODO: new_key migration support
  def symmetric_key
    key = Settings.secure_storage.send(name.underscore) || Settings.secure_storage.default
    # TODO: performance
    OpenSSL::Digest::SHA256.new(key).digest
  end
end
