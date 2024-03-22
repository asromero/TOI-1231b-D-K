#!/bin/bash
set -x

#ip -6 addr show eth0 for the eth_addr


source_dir="${SOURCE_DIR:-/data/}"
target_dir="${TARGET_DIR:-/home/toi1231brouter/FileDumpster}"
source_ip=$(ip route get 1 | awk '{print $7}')
target_ip="${TARGET_IP:-192.168.204.191}"
target_eth_addr="${TARGET_ETHERNET:-fe80::a63:99f8:596e:3279}"
target_username="${TARGET_USERNAME:-toi1231brouter}"
encryption_password="${ENCRYPTION_PASSWORD:-Password}"
camera_check_bypass="${CAMERA_BYPASS:-true}"


# Function to update known_hosts file
function update_known_hosts {
  ssh-keyscan -H "$target_ip" >> /root/.ssh/known_hosts
}
# Function to check if a file is not empty
function is_file_empty {
  if [ -s "$1" ]; then
    return 1 # File is not empty
  else
    return 0 # File is empty
  fi
}

while true; do

  if is_file_empty "$source_dir/pixycam_log.txt" && ! $camera_check_bypass; then
    echo "Pixy cam does not detect color, landing sequence aborted!" 2>&1
    sleep 2
    continue
  fi

  if ping6 -c 1 -I eth0 "$target_eth_addr" >/dev/null 2>&1; then
    # Both Pis have an inet6 address on eth0

    # Set your password
    tar -czvf - "$source_dir" | openssl enc -aes-256-cbc -salt -pbkdf2 -k "$encryption_password" -out encrypted_archive.enc

    # Transfer the encrypted archive to the remote server
    scp encrypted_archive.enc "$target_username@[${target_eth_addr}%eth0]":"$target_dir"

      if [ $? -eq 0 ]; then
      echo "Successfully transferred the files" 2>&1
      break;
      else
          echo "Error transferring files. Exit status: $?" 2>&1
          
      fi  
  else
     echo "Error: Unable to ping ethernet $target_eth_addr"2>&1
    
  fi

  sleep 5

 
done