class CreateEdis < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    create_table :edis, id: :uuid, default: -> {"uuid_generate_v4()"} do |t|
      t.text :file_content, null: false, default: ""
      t.json :parsed_content, null: false, default: {}
      t.json :parsing_errors, null: false, default: {}

      t.timestamps
    end
  end
end
