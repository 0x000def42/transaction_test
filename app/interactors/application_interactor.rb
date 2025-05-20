class ApplicationInteractor
  class Error < StandardError
    attr_reader :code

    def initialize(context)
      @code = context.error[:code]
      super(context.error[:message])
    end
  end

  class ApplicationContract < Dry::Validation::Contract; end

  class Context
    attr_reader :params, :current_user, :error

    attr_accessor :result

    def initialize(params:, current_user:)
      @params = params
      @current_user = current_user
      @error = nil
      @stacktrace = nil
      @result = nil
    end

    def success?
      !@error
    end

    def failure?
      !!@error
    end

    def fail!(error, message = nil)
      @error = { error:, message: }
      raise Error, self
    end

    def propogate_fail!(context)
      @error = context.error
    end
  end

  UUID_FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i
  attr_reader :context

  class << self
    def call(params:, current_user:, **kwargs)
      interactor = self.new(params:, current_user:, **kwargs)
      contract = fetch_contract!
      validation_result = validate_contract(params, contract, interactor)
      binding.irb # NOTE: Check validation result
      interactor.call
      interactor.context.result
    end

    def validate_contract(params, contract, interactor)
      contract.call(**params)
    end
  end

  def initialize(params:, current_user:)
    @context = Context.new(params, current_user)
  end

  private

  def fetch_contract!
    binding.irb # NOTE: fetch contract
  end
end
