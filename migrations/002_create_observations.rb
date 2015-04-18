Sequel.migration do
  change do
    create_table(:observations) do
      primary_key :id
      foreign_key :service_id, :services
      String :fingerprint, null:false, length:47
      Time :start, null:false
      Time :end, null:false
    end
  end
end