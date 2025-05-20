class Transfer < ApplicationRecord
  include AASM

  IMMEDIATE_TYPE = "immediate".freeze
  SCHEDULED_TYPE = "scheduled".freeze

  TYPES = [ IMMEDIATE_TYPE, SCHEDULED_TYPE ].freeze

  aasm column: :state do
    state :created, initial: true
    state :scheduled, :failed, :canceled, :completed

    event :schedule do
      transitions from: :created, to: :scheduled
    end

    event :fail do
      transitions from: %i[created scheduled], to: :failed
    end

    event :cancel do
      transitions from: %i[scheduled failed], to: :canceled
    end

    event :complete do
      transitions from: %i[created scheduled failed], to: :completed
    end
  end
end
