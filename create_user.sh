#!/bin/bash

# create_user.sh — Script to create a non-root, sudo user on a remote Debian 12 server via SSH as root.

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
WHITE=$'\033[1;37m'
NC=$'\033[0m' # No Color

COLUMNS=$(tput cols)
MAX_WIDTH=100
DISPLAY_WIDTH=$(( COLUMNS < MAX_WIDTH ? COLUMNS : MAX_WIDTH ))

echo
printf "${CYAN}%.0s═${NC}" $(seq 1 "$DISPLAY_WIDTH"); echo # L1 Separator
echo -e "  ${CYAN}create_user.sh${NC}"
printf "${CYAN}%.0s═${NC}" $(seq 1 "$DISPLAY_WIDTH"); echo # L1 Separator
echo -e "  This script allows you to set-up a ${WHITE}non-root${NC}, ${WHITE}sudo${NC} user"
echo -e "  for a remote ${WHITE}Debian 12${NC} server."
echo
echo -e "  Please ensure that the target server's root account"
echo -e "  is accessible via SSH password authentication."
echo
printf "  "; printf "%.0s─" $(seq 1 $((DISPLAY_WIDTH-2))); echo # L2 Separator
echo -e "  To proceed, please provide the following details..."
echo

# Prompt for server details (address + root password), then
# test if an SSH connection is actually able to be established.
while true; do
  # SERVER_ADDRESS
  while true; do
    read -e -p "  ${BLUE}Server Address (IP or domain): ${NC}" SERVER_ADDRESS

    # Validate - SERVER_ADDRESS cannot be empty.
    if [ -z "$SERVER_ADDRESS" ]; then
      echo
      echo -e "  ${RED}Server Address cannot be empty.${NC}"
      continue
    else
      break
    fi
  done

  # ROOT_PASSWORD
  while true; do
    read -e -s -p "  ${BLUE}Root Password (root@$SERVER_ADDRESS): ${NC}" ROOT_PASSWORD
    echo

    # Validate - ROOT_PASSWORD cannot be empty.
    if [ -z "$ROOT_PASSWORD" ]; then
      echo
      echo -e "  ${RED}Root Password cannot be empty.${NC}"
      continue
    else
      break
    fi
  done

  echo
  echo -e "  Checking SSH connection to ${WHITE}root@$SERVER_ADDRESS${NC}..."
  echo

  if sshpass -p "$ROOT_PASSWORD" ssh -o "StrictHostKeyChecking=no" root@"$SERVER_ADDRESS" "exit" > /dev/null 2>&1; then
    echo -e "  ${GREEN}[✔] SSH connection successful.${NC}"
    break
  else
    echo -e "  ${RED}[×] SSH connection failed.${NC}"
  fi
done

# Prompt for new user details
echo
printf "  "; printf "%.0s─" $(seq 1 $((DISPLAY_WIDTH-2))); echo # L2 Separator
echo -e "  New user creation — please provide the following..."
echo

# USERNAME
read -p "  ${BLUE}Username [admin]: ${NC}" USERNAME
USERNAME=${USERNAME:-admin} # Default to 'admin' if input is empty
echo -e "  Username set to ${GREEN}$USERNAME${NC}"
echo

# PASSWORD
echo "  ───"
while true; do
  read -s -p "  ${BLUE}Password for '$USERNAME':${NC} " PASSWORD
  echo

  # Validate - PASSWORD cannot be empty.
  if [ -z "$PASSWORD" ]; then
    echo
    echo -e "  ${RED}Password cannot be empty.${NC}"
    continue
  fi

  # Validate - PASSWORD must be at least 8 characters.
  if [ ${#PASSWORD} -lt 8 ]; then
    echo
    echo -e "  ${RED}Password must be at least 8 characters long.${NC}"
    continue
  fi

  read -s -p "  ${BLUE}Confirm Password for '$USERNAME': ${NC}" CONFIRM_PASSWORD
  echo

  if [ "$PASSWORD" == "$CONFIRM_PASSWORD" ]; then
    break
  else
    echo
    echo -e "  ${RED}Passwords do not match.${NC}"
  fi
done
echo -e "  Password set to ${GREEN}[hidden]${NC}"
echo

# PUBLIC_KEY
echo "  ───"
while true; do
  echo -e "  ${BLUE}Public Key for '$USERNAME' (e.g., 'ssh-rsa AAAA...')${NC}"
  read -p "  " PUBLIC_KEY
  echo
  echo -e "  Public Key for $USERNAME is:"
  echo -e "  ${YELLOW}$PUBLIC_KEY${NC}"
  echo
  read -p "  Is this correct (y/N)? " CONFIRM_PUBLIC_KEY
  CONFIRM_PUBLIC_KEY=$(echo "$CONFIRM_PUBLIC_KEY" | tr '[:upper:]' '[:lower:]') # Convert to lowercase

  if [ "$CONFIRM_PUBLIC_KEY" == "y" ]; then
    break
  else
    echo
    echo -e "  ${RED}Please re-enter the public key.${NC}"
    echo -e "  You must explicitly respond with 'y' to confirm"
  fi
done
echo
echo -e "  Public Key set to..."
echo -e "  ${GREEN}$PUBLIC_KEY${NC}"

echo
printf "  "; printf "%.0s─" $(seq 1 $((DISPLAY_WIDTH-2))); echo # L2 Separator
echo
echo -e "  ${YELLOW}Creating user '$USERNAME' on $SERVER_ADDRESS...${NC}"
echo

printf "*%.0s" $(seq 1 $((COLUMNS))); echo # sshpass output separator
echo "RUNNING COMMANDS AS ${WHITE}root@$SERVER_ADDRESS${NC}"
echo "See lines marked as '[RUN]' below."
echo "-----" 
echo

# Execute commands on the remote server via SSH
SSH_COMMAND_OUTPUT=$(sshpass -p "$ROOT_PASSWORD" ssh -o StrictHostKeyChecking=no root@"$SERVER_ADDRESS" 2>&1 << EOF
# Exit immediately if a command exits with a non-zero status.
set -e

# Create the user with specified shell, home directory, and add to sudo group
echo
echo "[RUN] useradd -m -s /bin/bash -G sudo \"$USERNAME\""
useradd -m -s /bin/bash -G sudo "$USERNAME"

# Set the user's password
echo
echo "[RUN] echo \"$USERNAME:$PASSWORD\" | chpasswd"
echo "$USERNAME:$PASSWORD" | chpasswd

# Create .ssh directory if it doesn't exist
echo
echo "[RUN] mkdir -p /home/\"$USERNAME\"/.ssh"
mkdir -p /home/"$USERNAME"/.ssh

# Append the public key to authorized_keys
echo
echo "[RUN] echo \"$PUBLIC_KEY\" >> /home/\"$USERNAME\"/.ssh/authorized_keys"
echo "$PUBLIC_KEY" >> /home/"$USERNAME"/.ssh/authorized_keys

# Set correct permissions and ownership
echo

echo "[RUN] chown -R \"$USERNAME\":\"$USERNAME\" /home/\"$USERNAME\"/.ssh"
chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh

echo "[RUN] chmod 700 /home/\"$USERNAME\"/.ssh"
chmod 700 /home/"$USERNAME"/.ssh

echo "[RUN] chmod 600 /home/\"$USERNAME\"/.ssh/authorized_keys"
chmod 600 /home/"$USERNAME"/.ssh/authorized_keys
EOF
)
SSH_EXIT_CODE=$?
echo "$SSH_COMMAND_OUTPUT"
printf "*%.0s" $(seq 1 $((COLUMNS))); echo # sshpass output separator

if [ $SSH_EXIT_CODE -ne 0 ]; then
  echo
  echo -e "  ${RED}[×] Something went wrong with creation of user '$USERNAME' on $SERVER_ADDRESS.${NC}"  
  echo -e "  See the output above for more information."
  echo
  printf "${CYAN}%.0s═${NC}" $(seq 1 "$DISPLAY_WIDTH"); echo # L1 Separator
  echo
  exit 1
fi

echo
echo -e "  ${GREEN}[✔] User '$USERNAME' successfully created!${NC}"
echo -e "  Run ${WHITE}'ssh $USERNAME@$SERVER_ADDRESS'${NC} to log-in."
echo
printf "${CYAN}%.0s═${NC}" $(seq 1 "$DISPLAY_WIDTH"); echo # L1 Separator
echo
exit 0
