# frozen_string_literal: true

class CreateServices < ActiveRecord::Migration[7.0]
  def change
    create_table :services do |t|
      t.string :scope, null: false
      t.string :name, null: false
      t.string :status, null: false
      t.boolean :hidden, null: false
      t.boolean :destroyable, null: false, default: true
      t.boolean :mirrorable, null: false, default: false

      t.timestamps
    end

    add_index :services, %i[scope name], unique: true
    add_index :services, :scope, where: "hidden = 'f'"
  end
end
