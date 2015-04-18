Sequel.migration do
  change do
    create_table(:services) do
      primary_key :id
      String :host, null:false
      String :port, null:false, length:5
      String :service_type, null:false, length:2

      index [:host, :port, :service_type], unique:true

      Time :last_request
      Time :last_observation_attempt
      Integer :auto_reobservation_count
    end
  end
end