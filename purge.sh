set -x
if dpkg -l | grep linux-azure | grep 6.2.0.1009 > /dev/null; then
    echo "Purging linux-azure 6.2 packages"
    # shellcheck disable=SC2046
    if ! DEBIAN_FRONTEND=noninteractive apt -y purge $(dpkg -l | awk '$2 ~ /linux.*azure/ && $3 ~ /^6\.2\.0.1009/ { print $2; }') &> /dev/null; then

        echo "Failed to purge linux-azure 6.2 packages"
        echo "NOTOK"
        sleep infinity
    fi
fi