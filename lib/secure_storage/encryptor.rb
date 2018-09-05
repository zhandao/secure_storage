module SecureStorage
  module Encryptor
    def encrypt(data)
      return if data.blank?
      cipher = OpenSSL::Cipher::AES256.new(:CBC)
      cipher.encrypt
      cipher.key = secure_storage_key
      data = cipher.update(data) << cipher.final
      Base64.strict_encode64(data)
    end

    def decrypt(data)
      return if data.blank?
      cipher = OpenSSL::Cipher::AES256.new(:CBC)
      cipher.decrypt
      cipher.key = secure_storage_key
      data = cipher.update(Base64.strict_decode64(data)) << cipher.final
      data.force_encoding('utf-8')
    end
  end
end
