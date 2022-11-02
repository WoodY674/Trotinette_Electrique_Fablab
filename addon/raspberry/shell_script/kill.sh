#required a sudo command to call the script
if [ -n "$1" ] && [ "$1" = "--second-method" -o "$1" = "-sm" ];
then
        pid_brut=$(get_pid.sh);
        after_pid=${pid_brut/*pid=/};
        pid=${after_pid/,*/};
        sudo kill -9 $pid;
        echo "mode 2"
else
        fuser -k 5000/tcp;
        echo "mode 1"
fi