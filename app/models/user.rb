class User < ApplicationRecord
    # ASSOCIATIONS
    has_many :tasks, dependent: :destroy
    
    # VALIDATIONS
    has_secure_password
    validates :username, presence: true, length: { minimum: 3, maximum: 25 }
    # validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :email, presence: true, uniqueness: true, format: { with: /\A[A-Za-z0-9._-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\z/ , message: "invalid email format"}
    validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

    # CALLBACKS
    before_validation :downcase_and_strip_email
    before_validation :ensure_username_has_value, on: [ :create, :update ]

    private

        def ensure_username_has_value
            if username.blank? && email.present?
                self.username = self.email
            elsif username.present?
                self.username = username.strip
            end
        end

        def downcase_and_strip_email
            self.email = (email || '').downcase.strip
        end
    
  end
  