class AddEventPictureToEvents < ActiveRecord::Migration
  def change
    add_column :events, :event_picture, :string
  end
end
