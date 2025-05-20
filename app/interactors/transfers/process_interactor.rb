module Transfers
  class ProcessInteractor < ApplicationInteractor
    class Contract < Dry::Validation::Contract
      params do
        required(:transfer_id).filled(:format, UUID_FORMAT)
      end
    end

    def call
      params = context.params
      current_user = context.current_user

      transfer = nil

      Transfer.transaction do
        transfer = fetch_transfer(params[:transfer_id])

        return if transfer_finished(transfer)

        wallets = fetch_wallets(transfer)
        sender_wallet = wallets[transfer.sender_wallet_id]
        recepient_wallet = wallets[transfer.recepient_wallet_id]

        check_user!(sender_wallet, current_user)

        move_funds(sender_wallet, recepient_wallet, transfer.amount)
        transfer.complete!

        context.result = { entity: transfer }
      end
    ensure
      transfer&.fail!
    end

    private

    def transfer_finished(transfer)
      transfer.completed? || transfer.canceled?
    end

    def check_user!(sender_wallet, current_user)
      context.fail!("PERMISSION_DENIED") unless sender_wallet.user_id != current_user.id
    end

    def move_funds(sender_wallet, recepient_wallet, amount)
      sender_wallet.update!(
        amount: sender_wallet.amount - amount,
        amount_reserve: sender_wallet.amount_reserve - amount
      )
      recepient_wallet.update!(
        amount: recepient_wallet.amount + amount
      )
    end

    def fetch_wallets(transfer)
      wallet_ids = [ transfer.sender_wallet_id, transfer.recepient_wallet_id ].sort
      wallets = Wallet.lock.where(id: wallet_ids).index_by(&:id)

      unless wallet_ids.all? { wallets.key?(it) }
        transfer.failure!
        context.fail!("NOT_FOUND", "Missing wallets '#{currency.code}' for users #{user_ids - wallets.keys}")
      end

      wallets
    end

    def fetch_transfer(transfer_id)
      Transfer.find_by!(uuid: transfer_id).lock
    end
  end
end
