class AddStatusCertificateToIntip < ActiveRecord::Migration[6.0]
  def change
    add_column :intips, :certificate_status, :integer
  end
end
