#!/bin/bash
# Generate fresh auth logs with today's date for dashboard testing
# Usage: ./generate_test_logs.sh

DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$DIR/test_auth_$(date +%Y%m%d).log"
DATE=$(date +"%b %d")

rm -f "$OUT"

# Failed SSH logins (T1110)
for i in 1 2 3 4 5 6; do
  HOUR=$(( (i + 1) % 24 ))
  MIN=$(( i * 7 ))
  IP="103.45.67.$((89 + i))"
  USER="oracle"
  if [ $(( i % 2 )) -eq 0 ]; then USER="admin"; fi
  printf "%s %02d:%02d:01 kali sshd[2210]: Failed password for invalid user %s from %s port 44212 ssh2\n" "$DATE" "$HOUR" "$MIN" "$USER" "$IP" >> "$OUT"
done

# Successful logins (T1078)
HOUR=9; MIN=15
printf "%s %02d:%02d:30 kali sshd[2250]: Accepted password for jane from 192.168.1.50 port 54000 ssh2\n" "$DATE" "$HOUR" "$MIN" >> "$OUT"
MIN=16
printf "%s %02d:%02d:31 kali sshd[2250]: session opened for user jane by (uid=1000)\n" "$DATE" "$HOUR" "$MIN" >> "$OUT"

# Sudo privilege escalation (T1548)
MIN=30
printf "%s %02d:%02d:00 kali sudo:     jane : TTY=pts/0 ; PWD=/home/jane ; USER=root ; COMMAND=/usr/bin/apt update\n" "$DATE" "$HOUR" "$MIN" >> "$OUT"
MIN=35
printf "%s %02d:%02d:05 kali sudo:     jane : TTY=pts/0 ; PWD=/home/jane ; USER=root ; COMMAND=/usr/bin/apt upgrade -y\n" "$DATE" "$HOUR" "$MIN" >> "$OUT"
MIN=40
printf "%s %02d:%02d:00 kali sudo: pam_unix(sudo:session): session opened for user root\n" "$DATE" "$HOUR" "$MIN" >> "$OUT"

# More successful logins spread through the day (so the timeline has multiple points)
for i in 0 1 2; do
  HOUR=$(( 10 + i * 3 ))
  MIN=$(( 5 + i * 10 ))
  IP="192.168.1.$((60 + i))"
  printf "%s %02d:%02d:30 kali sshd[2250]: Accepted password for kali from %s port 49872 ssh2\n" "$DATE" "$HOUR" "$MIN" "$IP" >> "$OUT"
  printf "%s %02d:%02d:31 kali sshd[2250]: session opened for user kali(uid=1000) by (uid=0)\n" "$DATE" "$HOUR" "$MIN" >> "$OUT"
done

echo "Generated $OUT with today's date"
echo "Upload to Splunk: Settings > Add Data > Upload > $OUT"
echo "Sourcetype: save | Index: main"
