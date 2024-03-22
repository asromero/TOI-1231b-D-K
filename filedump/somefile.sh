set -x
check_eth_connection() {
    local source_ip="$1"
    local target_ip="$2"
    
    # Get the network interface for the source IP
    local source_interface=$(ip -o -4 addr show | awk -v ip="$source_ip" '$0 ~ ip {print $2}' | cut -d'/' -f2)

    # Get the network interface for the target IP
    local target_interface=$(ip -o -4 addr show | awk -v ip="$target_ip" '$0 ~ ip {print $2}' | cut -d'/' -f2)

    # Check if both source and target are connected over eth0
    if [ "$source_interface" = "eth0" ] && [ "$target_interface" = "eth0" ]; then
        echo "Source IP is connected to the target IP over eth0"
        return 0  # Success
    else
        echo "Source IP or target IP is not connected over eth0"
        return 1  # Failure
    fi
}


# Example usage
source_ip="192.168.118.191"
target_ip="192.168.118.54"
if check_eth_connection "$source_ip" "$target_ip"; then
    echo "Proceed with the transfer"
else
    echo "Abort the transfer"
fi
