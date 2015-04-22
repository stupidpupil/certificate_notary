Sequel.migration do
  change do
    create_table(:certificates) do
      primary_key :id

      File :der_encoded

      String :md5, size:32, fixed:true
      String :sha256, size:64, fixed:true, index:{:unique=>true}, null:false

    end
  end
end