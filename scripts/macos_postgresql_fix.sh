#!/bin/bash

# If your system crashes or shuts-down hard, the PostgreSQL PID file is left
# behind and then it won't startup when your system restarts. Run this script
# to check if it's ok to delete the PID file and start PostgreSQL

prefix=$(brew --prefix)
pid_path="$prefix/var/postgres/postmaster.pid"

if [ ! -f "$pid_path" ]; then
  echo "🤔  No PID file exists at $pid_path. PostgreSQL was shut down properly?"
  exit 1
fi

pid=$(head -n1 "$pid_path")
cmd_at_pid=$(ps $pid -co "command=")

if [ "$cmd_at_pid" == "postgres" ]; then
    echo "⚠️  Postgres is running with PID $pid! Aborting"
    exit 1
fi

echo "👍  The existing PID file is can be deleted"
read -p "⁉️  Delete $pid_path? [y/n]: " delete

if [ "$delete" != "y" ]; then
    echo "👋  Ok, bye"
    exit 0
fi

rm "$pid_path";
echo "🤖  Re-loading PostgreSQL..."
brew services start postgresql

echo "🎉  It should be running now!"
brew services list
