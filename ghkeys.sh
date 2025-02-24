#!/bin/bash

echo "Write your GitHub Username from which you want to import keys:"

# GitHub username to fetch keys
GITHUB_USER="${1:-$(read -p 'Enter GitHub username: ' input; echo $input)}"

# Check if sudo is present
if command -v sudo &>/dev/null; then
    SUDO_CMD="sudo"
else
    SUDO_CMD=""
    echo "Warning: sudo is not installed. Running without elevated privileges."
fi

# Ensure curl is installed
if ! command -v curl &>/dev/null; then
    echo "curl is not installed. Attempting to install..."
    if command -v apt-get &>/dev/null; then
        $SUDO_CMD apt-get update && $SUDO_CMD apt-get install -y curl
    elif command -v yum &>/dev/null; then
        $SUDO_CMD yum install -y curl
    elif command -v dnf &>/dev/null; then
        $SUDO_CMD dnf install -y curl
    elif command -v zypper &>/dev/null; then
        $SUDO_CMD zypper install -y curl
    else
        echo "Error: Unable to install curl. Install it manually and rerun the script."
        exit 1
    fi
fi

# Define paths
SSH_DIR="$HOME/.ssh"
AUTHORIZED_KEYS_NEW="$SSH_DIR/authorized_keys_github"
SSHD_CONFIG_DIR="/etc/ssh/sshd_config.d"
SSHD_CONFIG_FILE="$SSHD_CONFIG_DIR/github_authorized_keys.conf"

# Ensure SSH directory exists
mkdir -p "$SSH_DIR"

# Fetch GitHub SSH keys
echo "Fetching SSH keys for GitHub user: $GITHUB_USER"
GITHUB_KEYS=$(curl -s "https://github.com/$GITHUB_USER.keys")

# Create a new authorized_keys file with the fetched keys
echo "$GITHUB_KEYS" > "$AUTHORIZED_KEYS_NEW"
chmod 600 "$AUTHORIZED_KEYS_NEW"

echo "Imported keys saved to: $AUTHORIZED_KEYS_NEW"

# Ensure SSH config directory exists
$SUDO_CMD mkdir -p "$SSHD_CONFIG_DIR"

# Create a new SSH configuration file
echo "Creating SSH configuration file: $SSHD_CONFIG_FILE"

echo -e "AuthorizedKeysFile .ssh/authorized_keys_github" | $SUDO_CMD tee "$SSHD_CONFIG_FILE" > /dev/null

# Set permissions for security
$SUDO_CMD chmod 644 "$SSHD_CONFIG_FILE"
$SUDO_CMD chown root:root "$SSHD_CONFIG_FILE"

echo "New SSH config added at: $SSHD_CONFIG_FILE"
echo "Restarting SSH service to apply changes..."
$SUDO_CMD systemctl restart ssh

echo "Setup complete. Your GitHub SSH keys are now in use!"
