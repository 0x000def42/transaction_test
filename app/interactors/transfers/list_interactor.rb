module Transfers
  class ListInteractor < ApplicationInteractor
    class Contract < ApplicationContract
      params do
        # ...
      end
    end

    def call
      current_user = context.current_user

      wallets = fetch_wallets(current_user)

      context.result = { entities: transfers }
    end

    private

    def fetch_wallets(user)
      user.wallets.includes(:currency, :transfers)
    end
  end
end
