class CreateMpGeometryTable < ActiveRecord::Migration
  def change
    create_table :mp_geometry do |t|
      t.geometry :mp

      t.timestamps
    end
  end
end
