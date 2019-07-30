# https://ankane.org/devise-argon2

module Argon2Encryptor
  def digest(klass, password)
    password = "#{password}#{klass.pepper}" if klass.pepper.present?
    ::Argon2::Password.create(password)
  end

  def compare(klass, hashed_password, password)
    return false if hashed_password.blank?

    if hashed_password.start_with?('$argon2')
      password = "#{password}#{klass.pepper}" if klass.pepper.present?
      ::Argon2::Password.verify_password(password, hashed_password)
    else
      super
    end
  end
end

Devise::Encryptor.singleton_class.prepend(Argon2Encryptor)
