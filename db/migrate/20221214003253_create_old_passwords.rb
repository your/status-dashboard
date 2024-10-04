# frozen_string_literal: true

class CreateOldPasswords < ActiveRecord::Migration[7.0]
  def change
    create_table :old_passwords do |t|
      t.string :encrypted_password, null: false
      t.string :password_archivable_type, null: false
      t.integer :password_archivable_id, null: false
      t.datetime :created_at
    end

    add_index :old_passwords, %i[password_archivable_type password_archivable_id], name: 'index_password_archivable'
  end
end
