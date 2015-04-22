Sequel.migration do
  up do
    Que.migrate! :version => 3
  end

  down do
    Que.migrate! :version => 0
  end
end