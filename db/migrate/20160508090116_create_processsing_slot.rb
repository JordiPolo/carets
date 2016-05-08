class CreateProcesssingSlot < ActiveRecord::Migration
  def change
    create_table :processing_slots do |t|
      # t.integer  :id
      t.string   :status
      t.datetime :slot_time
      t.timestamps
    end
  end
end
