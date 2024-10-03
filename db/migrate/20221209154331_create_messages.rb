# frozen_string_literal: true

class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.string :scope, null: false
      t.string :body, null: false

      t.timestamps
    end

    add_index :messages, %i[scope created_at], unique: true
  end
end
