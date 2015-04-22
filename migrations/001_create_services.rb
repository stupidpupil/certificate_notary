Sequel.migration do
  change do
    create_table(:services) do
      primary_key :id
      String :host, null:false
      String :port, null:false, size:5
      String :service_type, null:false, size:2

      index [:host, :port, :service_type], unique:true

      Time :last_request
      Time :last_observation_attempt
      Integer :error_count, default:0
    end
  end
end