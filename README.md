
# Born2beRoot

This project aims to guide you in setting up your first server by following specific rules.


``` 
Since the goal is to set up a server, you will install only the minimum required services. For this reason, 
a graphical user interface is not necessary. Therefore, it is prohibited to install X.org or any other equivalent graphical server. 

```

## Installation

Install virtualbox and download Debian iso


        https://www.virtualbox.org/wiki/Downloads
        https://www.debian.org/download


During the VM configuration, choose the option to manually partition the disk or select a custom partitioning scheme.


## SSH Configuration

A SSH service will be active only on port 4242. For security reasons, connecting via SSH as the root user will be disabled.

### install ssh

        sudo apt install openssh-server

To configure the SSH service accordingly, follow these steps:
1. Modify SSH configuration:    
 * Open the SSH configuration file using a text editor, for example:
           
         
            sudo nano /etc/ssh/sshd_config
        

 * Look for the line that specifies the SSH port (by default, it is Port 22) and change it to:

            Port 4242
2. Disable SSH access for the root user:
 * Search for the line PermitRootLogin in the SSH configuration file and modify it to disallow SSH access for the root user:

            PermitRootLogin no

3. Restart the SSH service:
* Save the changes made to the SSH configuration file and exit the text editor.
* Restart the SSH service to apply the changes:

        sudo service ssh restart


## Installing and configuring UFW (Uncomplicated Firewall)

You will configure your operating system using the UFW firewall (or the firewall for Rocky) to only allow port 4242 and block all other incoming connections.

### install UFW

        sudo apt install UFW


To configure the firewall accordingly, follow these steps:

1. Check UFW/firewall status:
* Open a terminal or command prompt and check the status of the UFW firewall using the following command:

        sudo ufw status

If UFW is not enabled, proceed to the next step. If it is enabled, you may need to modify the existing rules or disable it temporarily to apply the new configuration.

2. Set default policy:
* Set the default policy for incoming connections to deny all traffic:

        sudo ufw default deny incoming
        sudo ufw default deny outgoing

3. Allow SSH access on port 4242:

* Allow incoming SSH connections on port 4242:

        sudo ufw allow 4242

4. Enable the firewall:
* Enable the UFW firewall to enforce the configured rules:

        sudo ufw enable
5. Check the firewall status:
* Verify that the firewall is active and allowing only the desired port:

        sudo ufw status


## strong password policy

To enforce a strong password policy, you need to fulfill the following conditions:
### policy

* Password Expiration:
    
    * Set the password expiration period to 30 days.
    * This means users will be required to change their passwords every 30 days.
* Minimum Days Before Password Change:

    * Configure a minimum of 2 days before a password can be changed.
    * Users will need to wait at least 2 days before they can modify their passwords.
* Password Expiration Warning:

    * Set a password expiration warning period of 7 days.
    * Users will receive a notification 7 days before their password expires.
* Password Complexity:

    * Enforce a minimum password length of 10 characters.
    * Passwords must contain at least one uppercase letter and one digit.
    * Passwords must not have more than 3 consecutive identical characters.
    * Passwords must not contain the username
    * The following rule does not apply to the root user: the password must contain at least 7 characters that are not present in the old password
    * Root passwords should still follow other complexity requirements.


### policy implementation

1. Open the password policy configuration file using a text editor:

        sudo nanvimo /etc/login.defs

2. Modify the following lines in the file:

        PASS_MAX_DAYS 30
        PASS_MIN_DAYS 2
        PASS_WARN_AGE 7

3. Save the changes and exit the text editor.

4. To enforce password complexity requirements and restrictions, you can use tools like pam_pwquality or libpam-pwquality.
   
        PAM (Pluggable Authentication Modules) allows system administrators to choose how applications authenticate users.
           https://www.debian.org/doc/manuals/securing-debian-manual/ch04s11.en.html
   
 Install the package if it's not already available:

        sudo apt-get install libpam-pwquality
6. Edit the password policy configuration file:

        sudo nano /etc/pam.d/common-password

7. Add or modify the line containing pam_pwquality.so to include the desired password complexity options. For example:

        password    requisite    pam_pwquality.so retry=3 minlen=10 lcredit=-1 ucredit=-1 dcredit=-1 maxrepeat=3 usercheck=0 difok=7 reject_username enforce_for_root

* enforce_for_root enforces password complexity even for the root user.


After setting up your configuration files, it is necessary to change the passwords 
for all accounts on the virtual machine, including the root account. To change the passwords, follow these steps:

        passwd [username]

## install sudo and configuration

To establish a strict configuration within your sudo group, you need to fulfill the following conditions:

1. Limiting Authentication Attempts:

* Limit authentication using sudo to 3 attempts in case of an incorrect password.
2. Custom Error Message:

* Display a custom error message in case of a failed sudo password entry.
3. Logging of Sudo Actions:

* Archive every action that uses sudo, including both inputs and outputs.
* Store the sudo log in the directory /var/log/sudo/.
4. Enabling TTY Mode:

* Enable TTY mode for enhanced security.
5. Restricting Sudo Paths:

* Restrict the paths usable by sudo for security purposes.
    
    Example: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

### implementation

        sudo visudo

1. Scroll down or search for the line that starts with ```Defaults env_reset.```

2. Add or modify the following lines below that line:

        Defaults        passwd_tries=3         # Limit authentication attempts to 3
        Defaults        badpass_message="Your custom error message here"  # Custom error message
        Defaults        logfile="/var/log/sudo.log"     # Log sudo actions
        Defaults        log_input, log_output           # Log both inputs and outputs
        Defaults        requiretty                      # Enable TTY mode
        Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"   # Restrict sudo paths


 Replace "Your custom error message here" with your desired custom error message.

3. Save the changes and exit the editor.


## System Information Broadcast Script

This script is designed to periodically gather system information and broadcast it to all terminals using the `wall` command. It retrieves various system details such as OS architecture, kernel version, CPU information, memory usage, disk usage, network information, and more.

Usage:
1. Make sure the script is executable by running the command: `chmod +x script.sh`
2. Execute the script: `./script.sh`
3. The script will start gathering system information and broadcasting it to all terminals every 10 minutes.

Script Details:
- The script is written in Bash and runs in an infinite loop using the `while true` construct.
- System information is obtained using various Linux command-line tools and stored in variables.
- The gathered information is formatted into a message that includes details such as architecture, kernel version, CPU usage, memory usage, disk usage, network information, etc.
- The `wall` command is used to broadcast the message to all terminals, ensuring that all users are informed of the system information.
- After broadcasting the message, the script waits for 10 minutes using the `sleep` command before gathering and broadcasting the next set of information.

Information Gathered:
1. System Information:
   - OS Architecture: The architecture of the operating system.
   - Kernel Version: The version of the Linux kernel.
   - Physical Processors: The number of physical processors in the system.
   - Virtual Processors: The number of virtual processors in the system.

2. Memory Usage:
   - Memory Total: The total amount of memory in the system.
   - Memory Used: The amount of memory currently in use.
   - Memory Percentage: The percentage of memory used.
   - Memory Available: The amount of available memory.

3. Disk Usage:
   - Disk Total: The total disk space used by all partitions (excluding the boot partition).
   - Disk Used: The total disk space used in megabytes (excluding the boot partition).
   - Percentage Disk Usage: The percentage of disk space used by all partitions (excluding the boot partition).

4. CPU Usage:
   - CPU Usage: The overall CPU usage percentage.

5. Other System Information:
   - Last Reboot: The timestamp of the last system reboot.
   - LVM Status: The status of the Logical Volume Manager (LVM) - either "Active" or "Inactive".
   - Active Connections: The number of active network connections.
   - Active Users: The number of currently logged-in users.
   - IPv4 Address: The IPv4 address of the system.
   - MAC Address: The MAC address of the system.
   - Sudo Commands Executed: The number of sudo commands executed.

Note:
- This script may require root privileges to execute certain commands such as `lvs`, `ss`, and `sudo`.
- Make sure to review and understand the script before running it on your system.
- Use the script responsibly and only on systems where broadcasting system information is allowed and appropriate.


