@dir = "/home/ubuntu/tangshi/"

worker_processes 10
working_directory @dir

timeout 30

listen 4567

pid "#{@dir}/pids/unicorn.pid"

stderr_path "#{@dir}/logs/unicorn.stderr.log"
stdout_path "#{@dir}/logs/unicorn.stdout.log"
