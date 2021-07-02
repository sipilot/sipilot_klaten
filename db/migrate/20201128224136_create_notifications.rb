class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.integer :recipient_id
      t.integer :actor_id
      t.datetime :read_at
      t.boolean :notifiable_type
      t.integer :notifiable_id
      t.string :action
      t.text :message
      t.string :title

      t.timestamps
    end
  end
end
