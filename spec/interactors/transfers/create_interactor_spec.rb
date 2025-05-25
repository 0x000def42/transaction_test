RSpec.describe Transfers::CreateInteractor do

  let(:current_user) { sender }
  let(:sender) { create(:user, :with_wallet, amount: sender_amount) }
  let(:recepient) { create(:user) }
  let(:currency) { create(:currency) }

  let(:transfer_type) { Transfer::IMMEDIATE_TYPE }
  let(:execute_at) { nil }
  let(:amount) { "100.12" }
  let(:sender_amount) { 1_000 }

  let(:sender_wallet) { sender.wallets.first }

  let(:interactor) { described_class.call(params: params, current_user:) }

  let(:params) do
    {
      sender_id: sender.uuid,
      recepient_id: recepient.uuid,
      amount:,
      currency_code: currency.code,
      transfer_type:,
      execute_at:,
    }
  end

  it "works correct" do
    expect(interactor).to be_success
  end

  context "with stubbed process interactor" do
    before do
      allow(Transfers::ProcessInteractor).to receive(:call) do |arg|
        double('transfer', result: {
          entity: Transfer.find_by!(uuid: arg[:params][:transfer_id])
        })
      end
    end

    it "works correct" do
      expect do
        expect(interactor).to be_success

        sender_wallet.reload
      end.to change(sender_wallet, :reserve_amount).from(0).to(currency.convert_amount(amount).to_i)

      expect(interactor.result[:entity]).to have_attributes(
        amount: currency.convert_amount(amount).to_i,
        transfer_type: Transfer::IMMEDIATE_TYPE,
        sender_wallet_id: sender.wallets.first.id,
        recepient_wallet_id: recepient.wallets.first.id,
        currency_id: currency.id,
        state: "created",
        execute_at: nil
      )
    end
  end

  context "when recepient wallet not exist" do
    #
  end

  context "when sender wallet is locked" do
    #
  end

  context "when recepient and sender are same" do
    #
  end

  context "when sender not current user" do
    #
  end

  context "when currency not exist" do

  end

  context "when sender not exist" do

  end

  context "when recepient not exist" do

  end

  context "when insuffient funds" do

  end

  context "when amount has too many decimal places" do

  end

  context "when execute_at not nil on immediate type" do
    #
  end

  context "when scheduled type" do
    it do
      #
    end

    context "when execute_at is a past" do
      #
    end

    context "when execute_at is nil" do
      #
    end
  end
end
