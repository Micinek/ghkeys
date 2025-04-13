# GitHub SSH Keys Importer

This Bash script retrieves SSH public keys from a specified GitHub account and configures your SSH daemon to authenticate using these keys. It saves the keys in a dedicated file within your home directory and creates a separate SSH daemon configuration file that references this file. This approach ensures that automatically generated keys by other system services (for example, ProxmoxVE) remain unaffected.

## Features

- **Automatic GitHub Key Retrieval:** Fetches the public SSH keys from a specified GitHub account.
- **User-Friendly:** Prompts for a GitHub username if none is provided as an argument.
- **Dependency Management:** Checks for the presence of `curl` and attempts to install it if missing.
- **System & User Separation:**  
  - The keys are stored in the current user’s `~/.ssh/authorized_keys_github`.
  - The SSH daemon configuration file is created under `/etc/ssh/sshd_config.d` using sudo (if available).
- **Security:** Sets proper permissions for both the authorized keys file and the SSH configuration file.
- **Service Restart:** Automatically restarts the SSH service after applying changes.

## Use Cases

- **Quick Setup for SSH Authentication:** Easily import GitHub SSH keys to streamline the login process without manually managing keys.
- **Centralized Key Management:** Manage authorized keys centrally by leveraging GitHub as your key repository.
- **Multi-User Environments:** Use the provided SSH daemon configuration to ensure each user's home directory is correctly referenced for their authorized keys.

## Requirements

- **Operating System:** Linux (with systemd-based service management)
- **Tools:**  
  - Bash  
  - `curl` (the script will attempt to install it if missing)  
  - `sudo` (for creating system-level configuration files)  
- **Privileges:** Sudo privileges are required for system-wide configuration changes and restarting the SSH daemon.

## Running localy

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/Micinek/ghkeys.git
   cd ghkeys
   ```

2. **Make the Script Executable:**

   ```bash
   chmod +x ghkeys.sh
   ```

## Running directly from web

You can run the script directly from the GitHub repository without needing to clone or install anything locally. Just execute the following command:

```bash
curl -fsSL https://raw.githubusercontent.com/Micinek/ghkeys/main/ghkeys.sh | bash
```

This command uses `curl` to fetch the latest version of `ghkeys.sh` from the [ghkeys repository](https://github.com/Micinek/ghkeys/) and pipes it directly to `bash` for execution.

## Usage

Run the script by providing a GitHub username as an argument or by entering it when prompted:

```bash
./ghkeys.sh your_github_username
```

The script will:
1. Check for `sudo` and `curl`, installing curl if necessary.
2. Create your local `~/.ssh` directory if it doesn't exist.
3. Fetch the public SSH keys from `https://github.com/"your_github_username".keys`.
4. Save these keys into `~/.ssh/authorized_keys_github` with secure permissions.
5. Create an SSH daemon configuration file at `/etc/ssh/sshd_config.d/github_authorized_keys.conf` with the following content:

   ```plaintext
   AuthorizedKeysFile .ssh/authorized_keys_github
   ```

   *Note:* Because the file path is relative (does not start with a `/`), the SSH daemon automatically prepends each user’s home directory when looking up the authorized keys file.

6. Restart the SSH service so that the new configuration takes effect.

## How It Works

- **Authorized Keys File:**  
  The script downloads the GitHub SSH keys and writes them to `~/.ssh/authorized_keys_github`. Since the SSH daemon interprets relative paths in the `AuthorizedKeysFile` directive as relative to the user’s home directory, each user will have their keys read from `~/.ssh/authorized_keys_github`.

- **SSH Daemon Configuration:**  
  The configuration file placed in `/etc/ssh/sshd_config.d` tells the SSH daemon to use the `.ssh/authorized_keys_github` file from each user’s home directory. This ensures that the keys imported from GitHub are recognized during authentication.

## Troubleshooting

- **SSH Connection Refused:**  
  If SSH connections fail after running the script, verify:
  - The configuration file is in the correct directory (`/etc/ssh/sshd_config.d`).
  - The SSH service restarted properly. You may try restarting it manually:
    ```bash
    sudo systemctl restart sshd
    ```
  - The authorized keys file exists in your home directory and has proper permissions (600).

- **Missing Dependencies:**  
  Make sure `curl` is installed. The script will attempt to install it, but you may need to run the installation command manually if your package manager requires additional confirmation.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
