Sequel.migration do
  change do
    create_table(:timespans) do
      primary_key :id
      foreign_key :service_id, :services, null:false, index:true
      foreign_key :certificate_id, :certificates, null:false

      Time :start, null:false
      Time :end, null:false
    end
  end
end