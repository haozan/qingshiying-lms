class AddLinkUrlToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :link_url, :string

  end
end
