namespace :que do
  task :work do
    require 'certificate_notary'

    Que.mode          = :async

    stop = false
    %w( INT TERM ).each do |signal|
      trap(signal) {stop = true}
    end

    at_exit do
      $stdout.puts "Finishing Que's current jobs before exiting..."
      Que.worker_count = 0
      Que.mode = :off
      $stdout.puts "Que's jobs finished, exiting..."
    end

    loop do
      sleep 0.01
      break if stop
    end
  end
end