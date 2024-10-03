# frozen_string_literal: true

module HasScope
  extend ActiveSupport::Concern

  VALID_SCOPES = %w[internal external].freeze

  included do
    validates :scope, inclusion: { in: VALID_SCOPES }
  end
end
