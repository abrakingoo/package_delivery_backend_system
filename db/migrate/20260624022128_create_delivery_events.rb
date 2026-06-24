class CreateDeliveryEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :delivery_events, id: :uuid do |t|
      t.references :delivery_request, null: false, foreign_key: true, type: :uuid
      t.string :event_type
      t.jsonb :metadata

      t.timestamps
    end
  end
end
