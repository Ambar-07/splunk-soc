#!/bin/bash
# Setup Linux auth log monitoring in Splunk
# This creates a monitor input so Splunk watches the file automatically

set -e

echo "=== Splunk Linux Monitor Setup ==="

# Create log directory
sudo mkdir -p /var/log/splunk-monitor
echo "[1/4] Created /var/log/splunk-monitor"

# Create inputs.conf in the search app
sudo mkdir -p /opt/splunk/etc/apps/search/local/
if [ -f /opt/splunk/etc/apps/search/local/inputs.conf ]; then
  sudo cp /opt/splunk/etc/apps/search/local/inputs.conf /opt/splunk/etc/apps/search/local/inputs.conf.bak
fi

sudo bash -c 'cat > /opt/splunk/etc/apps/search/local/inputs.conf <<EOF
[monitor:///var/log/splunk-monitor/*.log]
disabled = false
index = main
sourcetype = save
host = kali
EOF'
echo "[2/4] Created inputs.conf monitoring /var/log/splunk-monitor/*.log"

# Copy the sample log so Splunk indexes it
sudo cp /home/kali/splunk-soc-dashboard/test_auth_20260806.log /var/log/splunk-monitor/test_auth.log 2>/dev/null || echo "[skip] no test log found"
echo "[3/4] Copied test log"

# Restart Splunk
sudo /opt/splunk/bin/splunk restart
echo "[4/4] Splunk restarted"

echo ""
echo "=== Done! Data should now be indexed ==="
echo "To add more logs: cp yourfile.log /var/log/splunk-monitor/"
echo "Splunk will index them automatically within seconds."
