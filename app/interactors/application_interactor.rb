class ApplicationInteractor
  class Error < StandardError
    attr_reader :code

    def initialize(context)
      @code = context.error[:code]
      message = context.error[:message]
      super_message = "#{context.klass} #{@code}"
      super(super_message)
    end
  end

  class ApplicationContract < Dry::Validation::Contract
    TypeContainer = Dry::Schema::TypeContainer.new
    TypeContainer.register("params.uuid", Dry::Types["strict.string"].constrained(format: Constants::UUID_REGEX))
  
    config.types = TypeContainer
  end

  class Context
    attr_reader :params, :current_user, :error, :klass

    attr_accessor :result

    def initialize(params, current_user, klass)
      @params = params
      @current_user = current_user
      @error = nil
      @stacktrace = nil
      @result = nil
      @klass = klass
    end

    def success?
      !@error
    end

    def failure?
      !!@error
    end

    def fail!(code, message = nil)
      @error = { code:, message: }
      raise Error, self
    end

    def propogate_fail!(context)
      @error = context.error
    end
  end

  attr_reader :context

  class << self
    def call(params:, current_user:, **kwargs)
      interactor = self.new(params:, current_user:, **kwargs)
      contract = fetch_contract!
      validation_result = validate_contract(params, contract, interactor)
      binding.irb if validation_result.failure? # NOTE: Check validation result
      interactor.call
      interactor.context
    end

    def validate_contract(params, contract, interactor)
      contract.call(**params)
    end

    private

    def fetch_contract!
      self::Contract.new
    end
  end

  def initialize(params:, current_user:)
    @context = Context.new(params, current_user, self.class)
  end

  private


end
