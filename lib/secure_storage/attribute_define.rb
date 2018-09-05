module SecureStorage
  module AttributeDefine
    def attribute_define; proc do |attr|
      define_method(attr) do
        begin
          instance_variable_get("@#{attr}") ||
              instance_variable_set("@#{attr}", decrypt(send(secure_name_for attr)))
        rescue ArgumentError # invalid base64
          send(secure_name_for attr).tap { |raw_val| update!(attr => raw_val) }
        end
      end

      define_method("#{attr}=") do |value|
        send("#{secure_name_for(attr)}=", encrypt(value))
        instance_variable_set("@#{attr}", value)
      end

      # TODO
      define_method("#{attr}?") do
        value = send(attr)
        value.respond_to?(:empty?) ? !value.empty? : !!value
      end

      define_method(:attributes) { super().merge!(attr => send(attr)).stringify_keys! }

      define_singleton_method("find_by_#{attr}") { |value| xfind_by(attr => value) }
    end end
  end
end
