module Transfers
  class CreateInteractor < ApplicationInteractor
    class Contract < ApplicationContract
      params do
        required(:sender_id).filled(:uuid)
        required(:recepient_id).filled(:uuid)
        required(:amount).filled(:decimal)
        required(:currency_code).filled(:string)
        required(:transfer_type).filled(included_in?: Transfer::TYPES)
        optional(:execute_at) # datetime
      end

      rule(:recepient_id, :sender_id) # not same

      rule(:execute_at) # more than now
    end

    def call
      params = context.params
      current_user = context.current_user

      sender = fetch_sender(params[:sender_id], current_user)
      recepient = fetch_recepient(params[:recepient_id])

      currency = fetch_currency(params[:currency_code])
      amount = parse_amount_to_int(params[:amount], currency)

      transfer = nil

      Transfer.transaction do
        sender_wallet = fetch_sender_wallet(sender, currency)
        check_wallet_amount!(sender_wallet, amount)

        recepient_wallet = fetch_recepient_wallet(recepient, currency)

        created_transfer = create_transfer(sender_wallet, recepient_wallet, currency, params)
        reserve_funds(sender_wallet, amount)

        transfer = process_or_enqueue_transfer(created_transfer)

        context.result = { entity: transfer }
      end
    end

    private

    def process_or_enqueue_transfer(transfer, current_user)
      process_transfer!(transfer, current_user) if transfer.transfer_type == Transfer::IMMEDIATE_TYPE
      enqueue_transfer!(transfer) if transfer.transfer_type == Transfer::SCHEDULED_TYPE
    end

    def process_transfer!(transfer, current_user)
      result = ProcessInteractor.call(params: { transfer_id: transfer.uuid }, current_user:)
      result[:entity]
    end

    def enqueue_transfer!(transfer)
      ProcessTransferJob.set(wait_until: transfer.execute_at).perform_later(transfer.id)
      transfer.schedule!
      transfer
    end

    def reserve_funds(sender_wallet, amount)
      sender_wallet.update(
        reserve_amount: sender_wallet.reserve_amount + amount
      )
    end

    def create_transfer(sender_wallet, recepient_wallet, currency, params)
      amount, transfer_type, execute_at = params.values_at(:amount, :transfer_type, :execute_at)
      Transfer.create(
        sender_wallet_id: sender_wallet.id,
        recepient_wallet: recepient_wallet.id,
        currency_id: currency.id,
        amount:,
        transfer_type:,
        execute_at:
      )
    end

    def check_wallet_amount!(sender_wallet, amount)
      context.fail!("INSUFFIENT_FUNDS") if (sender_wallet.amount - sender_wallet.reserve_amount) < amount
    end

    def fetch_recepient_wallet(recepient, currency)
      wallet = Wallet.find_by(user_id: recepient.id, currency_id: currency.id)
      unless wallet
        Wallet.upsert({ user_id: recepient.id, currency_id: currency.id },
          unique_by: %i[user_id currency_id],
          returning: false
        )
        wallet = Wallet.find_by(user_id: recepient.id, currency_id: currency.id)
      end

      wallet
    end

    def fetch_sender_wallet(sender, currency)
      Wallet.lock.find_by!(user_id: user_ids, currency_id: currency.id)
    end

    def parse_amount_to_int(amount, currency)
      real_amount = amount * (10**currency.precision)
      context.fail!("INVALID_AMOUNT") if real_amount.frac != 0 || real_amount <= 0
      real_amount.to_i
    end

    def fetch_sender(sender_id)
      sender = User.find_by!(uuid: sender_id)
      context.fail!("FORBIDDEN") unless sender.id != current_user.id
      sender
    end

    def fetch_recepient(recepient_id)
      User.find_by!(uuid: recepient_id)
    end
  end
end
