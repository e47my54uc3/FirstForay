#! /bin/sh
DAEMON="`which unicorn_rails`"
# sample example : DAEMON_OPTS="-p 5000 -c /home/ubuntu/reech/config/unicorn.rb -D"
DAEMON_OPTS=$REECH_UNICORN_OPTS
NAME="Unicorn Server"
DESCRIPTION=" === Unicorn Server for Reech App === "
# sample example for PID path PID='/home/ubuntu/reech/shared/pids/unicorn.pid'
PID=$REECH_UNICORN_PID

case "$1" in
  start)
    echo -n "Starting $DESCRIPTION "
    $DAEMON $DAEMON_OPTS
    echo "$NAME is running..."
    ;;
  stop)
    echo -n "Stopping $DESCRIPTION "
        kill -QUIT `cat $PID`
    echo "$NAME has been stopped..."
    ;;
  restart)
    echo -n "Restarting $DESCRIPTION "
        kill -QUIT `cat $PID`
    sleep 1
    $DAEMON $DAEMON_OPTS
    echo "$NAME has been restated...."
    ;;
  reload)
        echo -n "Reloading Configuration $DESCRIPTION "
        kill -HUP `cat $PID`
        echo "$NAME configuration has been reloaded..."
        ;;
  *)
    echo "Usage: $NAME {start|stop|restart|reload}" >&2
    exit 1
    ;;
esac
exit 0
