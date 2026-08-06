#!/bin/bash
# Generate mock Linux security events for Splunk dashboard testing
# Usage: ./generate_mock_data.sh <number_of_events>

NUM_EVENTS=${1:-100}
SPLUNK_HEC_URL="http://localhost:8088"
SPLUNK_HEC_TOKEN="your-hec-token"

EVENT_TYPES=("sshd: Failed password" "sshd: Accepted publickey" "sudo: COMMAND" "login: FAILED LOGIN" "kernel: firewall" "audit: EXECVE" "crond: CMD" "postfix/smtpd" "sshd: Connection closed")
SEVERITIES=("info" "warning" "critical" "info" "info" "info" "info" "warning" "warning")
HOSTS=("web-server-01" "db-server-02" "app-server-03" "mail-server-04" "proxy-server-05")
USERS=("root" "admin" "john" "jane" "service" "unknown")
ACTIONS=("success" "failure" "success" "failure" "success")

echo "Generating $NUM_EVENTS mock events..."

for i in $(seq 1 $NUM_EVENTS); do
    EVENT_IDX=$((RANDOM % ${#EVENT_TYPES[@]}))
    SEVERITY_IDX=$((RANDOM % ${#SEVERITIES[@]}))
    HOST_IDX=$((RANDOM % ${#HOSTS[@]}))
    USER_IDX=$((RANDOM % ${#USERS[@]}))
    ACTION_IDX=$((RANDOM % ${#ACTIONS[@]}))
    
    TIMESTAMP=$(date -u -d "$(( RANDOM % 24 )) hours ago" +"%Y-%m-%dT%H:%M:%S" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S")
    
    EVENT=$(cat <<EOF
{
  "time": "$(date +%s)",
  "host": "${HOSTS[$HOST_IDX]}",
  "source": "/var/log/auth.log",
  "sourcetype": "linux_secure",
  "event": {
    "timestamp": "${TIMESTAMP}",
    "severity": "${SEVERITIES[$SEVERITY_IDX]}",
    "event_type": "${EVENT_TYPES[$EVENT_IDX]}",
    "host": "${HOSTS[$HOST_IDX]}",
    "src": "$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255))",
    "user": "${USERS[$USER_IDX]}",
    "action": "${ACTIONS[$ACTION_IDX]}",
    "message": "${EVENT_TYPES[$EVENT_IDX]} for user ${USERS[$USER_IDX]} from 192.168.1.$((RANDOM % 255))"
  }
}
EOF
)

    echo "Event $i: ${EVENT_TYPES[$EVENT_IDX]} - ${SEVERITIES[$SEVERITY_IDX]}"
    
    # Uncomment and configure HEC token to send to Splunk
    # curl -s -k "$SPLUNK_HEC_URL/services/collector/event" \
    #   -H "Authorization: Splunk $SPLUNK_HEC_TOKEN" \
    #   -d "$EVENT"
    
    sleep 0.1
done

echo "Done! Generated $NUM_EVENTS mock events."
echo ""
echo "To send these events to Splunk, configure the HEC token and uncomment the curl command."
