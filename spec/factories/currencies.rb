FactoryBot.define do
  factory :currency do
    code { "USD" }
    name { "USD" }
    precision { 2 }
    initialize_with { Currency.find_or_initialize_by(code: code) }
  end
end
