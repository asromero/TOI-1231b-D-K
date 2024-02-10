#!/bin/bash
set -x
# Define the IP addresses of the two Raspberry Pis
pi1_ip="192.168.204.53"  # Replace with the actual IP of the first Pi
pi2_ip="192.168.204.191"  # Replace with the actual IP of the second Pi
# Define the source directory
source_dir="${SOURCE_DIR:-/data/}"

target_dir="/home/toi1231brouter/FileDumpster"

# Function to check if an inet6 address is present on eth0
function check_inet6 {
  local interface="eth0"
  local inet6_result
  inet6_result=$(ip -6 addr show "$interface" | grep "inet6")
  if [ -n "$inet6_result" ]; then
    echo "IPv6 address found on $interface"
    return 0  # Success
  else
    echo "No IPv6 address found on $interface"
    return 1  # Failure
  fi
}


if check_inet6 "$pi1_ip" && check_inet6 "$pi2_ip"; then
  # Both Pis have an inet6 address on eth0

  # Set your password
  password="Password"

  
 
  tar -czvf - "$source_dir" | openssl enc -aes-256-cbc -salt -pbkdf2 -k "$password" -out encrypted_archive.enc

  # Transfer the encrypted archive to the remote server
  scp encrypted_archive.enc toi1231brouter@192.168.204.53:"$target_dir"

  # Remove the temporary encrypted archive (optional)
#  rm encrypted_archive.enc
	echo "Sucessfully transferred the files" 2>&1
  
else
    echo "One or both Raspberry Pis do not have an inet6 address on eth0..." 2>&1
fi
