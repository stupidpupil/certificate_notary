module PerspectivesNotary
  class Service < Sequel::Model
    one_to_many :observations

    def id_string
      return "#{host}:#{port},#{service_type}"
    end

  end
end