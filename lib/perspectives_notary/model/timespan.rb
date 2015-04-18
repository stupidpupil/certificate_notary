module PerspectivesNotary
  class Timespan < Sequel::Model(DB[:timespans].order(Sequel.asc(:end)))
    many_to_one :service
    many_to_one :certificate


  end
end