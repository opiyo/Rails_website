rails_root = File.expand_path('../../', __FILE__)

worker_processes 2
working_directory rails_root

listen "/tmp/unicorn.sock"
pid "#{rails_root}/tmp/unicorn.pid"

# Set the path of the log files inside the log folder of the testapp
stderr_path "#{rails_root}/log/unicorn_err.log"
stdout_path "#{rails_root}/log/unicorn_out.log"