RSpec.describe Transfers::CreateInteractor do
  let(:sender) { create(:user) }
  let(:recepient) { create(:recepient) }
  let(:currency) { create(:currency) }

  let(:transfer_type) { Tansfer::IMMEDIATE_TYPE }
  let(:execute_at) { nil }

  let(:params) do
    {
      sender_id: sender.uuid,
      recepient_id: recepient.uuid,
      amount:,
      currency_code: currenct.code,
      transfer_type:,
      execute_at:,
    }
  end

  it "works correct" do
    #
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
