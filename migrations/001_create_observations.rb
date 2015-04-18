Sequel.migration do
  change do
    create_table(:observations) do
      primary_key :id
      String :service, null:false, index:true
      String :fingerprint, null:false, length:47
      Time :start, null:false
      Time :end, null:false
    end
  end
end