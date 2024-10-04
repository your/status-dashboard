# frozen_string_literal: true

class AddUpdatedByToMessageAndService < ActiveRecord::Migration[7.0]
  def change
    add_reference :messages, :updated_by, null: true, foreign_key: { to_table: :users }
    add_reference :services, :updated_by, null: true, foreign_key: { to_table: :users }
  end
end
