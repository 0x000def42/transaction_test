class Currency < ApplicationRecord
  class Amount
    def initialize(amount, precision)
      @decimal = BigDecimal(amount.to_s) * 10**precision
      @valid = @decimal.frac == 0
    end

    def valid? = @valid

    def to_i = @decimal.to_i
  end

  def convert_amount(amount)
    Amount.new(amount, precision)
  end
end