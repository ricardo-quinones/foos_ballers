module ApiErrors
  class ApiStandardError < StandardError
    attr_reader :status, :developer_error, :messages

    def initialize
      @developer_error = 'An unexpected error happened',
      @messages        = ['Sorry, we could not complete your request']
    end

    def as_json
      {
        developer_error: @developer_error,
        messages:        @messages
      }
    end
  end

  class LoginError < ApiStandardError
  end

  class EmailNotFoundError < LoginError
    def initialize
      @developer_error = 'No player found with that email'
      @messages        = ["Oops, looks like you're not signed up with us. Sign up below."]
      @status          = :not_found
    end
  end

  class AuthenticationError < LoginError
    def initialize
      @developer_error = 'Invalid credentials'
      @messages        = ["Sorry, couldn't log you in with those credentials"]
      @status          = :unauthorized
    end
  end

  class AuthTokenNotFoundError < ApiStandardError
    def initialize
      @developer_error = 'Auth token was not found'
      @messages        = ["Sorry, we could not complete your request"]
      @status          = :not_found
    end
  end
end