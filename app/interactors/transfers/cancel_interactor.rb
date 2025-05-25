module Transfers
  class CancelInteractor < ApplicationInteractor
    class Contract < ApplicationContract
      params do
        required(:transfer_id).filled(:uuid)
      end
    end

    def call
      params = context.params
      current_user = context.current_user

      Transfer.transaction do
        transfer = fetch_transfer(params[:transfer_id])
        check_ownership!(transfer, current_user)
        check_allow_to_cancel!(transfer)
        transfer.cancel!

        context.result = { entity: transfer }
      end
    end

    private

    def fetch_transfer(transfer_id)
      Transfer.lock.find_by!(uuid: transfer_id)
    end

    def check_ownership!(transfer, current_user)
      context.fail!("FORBIDDEN")  unless transfer.sender_wallet.user_id == current_user.id
    end

    def check_allow_to_cancel(transfer)
      # NOTE: Из вариантов - можно использовать guard-ы в стейт-машине
      context.fail!("INVALID_TRANSFER_TYPE") unless transfer.transfer_type == Transfer::SCHEDULED_TYPE
      context.fail!("INVALID_STATUS") unless transfer.may_cancel?
      context.fail!("EXPIRED") unless transfer.execute_at <= Time.zone.now
    end
  end
end
