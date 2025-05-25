FactoryBot.define do
  factory :user do
    trait :with_wallet do
      transient do
        currency { Currency.find_by(code: "USD") || create(:currency, code: "USD") }
        amount { 0 }

        after(:create) do |user, context|
          real_amount = context.currency.convert_amount(context.amount)
          create :wallet, currency_id: context.currency.id, user_id: user.id, amount: real_amount.to_i
        end
      end
    end
  end
end
