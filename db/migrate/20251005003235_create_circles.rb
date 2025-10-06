class CreateCircles < ActiveRecord::Migration[8.0]
  def change
    create_table :circles do |t|
      t.decimal :x, precision: 12, scale: 6
      t.decimal :y, precision: 12, scale: 6
      t.decimal :diameter, precision: 12, scale: 6
      t.references :frame, null: false, foreign_key: true

      t.timestamps
    end
  end
end
