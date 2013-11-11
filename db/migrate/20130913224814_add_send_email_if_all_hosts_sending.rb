class AddSendEmailIfAllHostsSending < ActiveRecord::Migration
  def change
    add_column :logs, :send_email, :boolean, default: false
  end
end
