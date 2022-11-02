#required to use 'sudo' to write in systemd services
FILE="batinette.service";
SYSTEM_D_PAT="/etc/systemd/system/"

SERVICE="[Unit]
Description=api batinette, to get batinette data
After=network.target syslog.target network-online.target
Wants=network.target

[Service]
Type=simple
User=emerick
WorkingDirectory=/var/api/
ExecStart=sh shell_script/start.sh
Restart=always
KillMode=process

[Install]
WantedBy=multi-user.target"

printf "$SERVICE" > "$SYSTEM_D_PAT$FILE"

sudo systemd enable $FILE