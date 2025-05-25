class TransfersController < ApplicationController
  def index
    result = ::Transfer::ListInteractor.call(
      params: {}, # Можно добавить фильтрацию транзакций по конкретным кошелькам
      current_user:
    )

    render json: { # Можно через jbuilder по views
      transfers: result[:entities].each do |transfer|
        {
          id: result.uuid,
          state: result.state
        }
      end
    }
  end

  def create
    result = ::Transfers::CreateInteractor.call(
      params: params.permit!.to_h,
      current_user:
    )

    render json: {
      transfer: {
        id: result.uuid,
        state: result.state
      } # whatever you want
    }
  end

  def cancel
    result = ::Transfers::CancelInteractor.call(
      params: params.permit!.to_h,
      current_user:
    )

    render json: {
      transfer: {
        id: result.uuid,
        state: result.state
      }
    }
  end
end
