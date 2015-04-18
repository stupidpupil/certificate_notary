Sequel.migration do
  change do
    create_table(:services) do
      primary_key :id
      String :host, null:false, index:true
      String :port, null:false, length:5
      String :service_type, null:false, length:2

      Time :last_request
      Time :last_observation_attempt
    end
  end
end