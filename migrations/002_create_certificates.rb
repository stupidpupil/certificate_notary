Sequel.migration do
  change do
    create_table(:certificates) do
      primary_key :id

      File :der_encoded

      String :md5, length:32, fixed:true
      String :sha256, length:64, fixed:true, index:true

    end
  end
end