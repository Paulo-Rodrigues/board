class CreateFrames < ActiveRecord::Migration[8.0]
  def change
    create_table :frames do |t|
      t.decimal :x, precision: 12, scale: 6
      t.decimal :y, precision: 12, scale: 6
      t.decimal :width, precision: 12, scale: 6
      t.decimal :height, precision: 12, scale: 6

      t.timestamps
    end
  end
end
