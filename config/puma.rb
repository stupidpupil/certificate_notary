workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 1)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 9292
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  CertificateNotary::DB.disconnect
  Que.mode = CertificateNotary::Config.que_in_web_process ? :async : :off

end