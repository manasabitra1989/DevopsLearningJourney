\# Linux for DevOps - Essential Commands and Notes



This repository contains a quick reference guide of Linux commands commonly used in DevOps. It includes system administration, networking, file management, permissions, process monitoring, logs, security, Docker, Kubernetes, and automation commands.



\---



\## 1. System Information



\- `uname -a`

&#x20; - Displays the Linux kernel version, operating system information, and machine details.

&#x20; - Useful for checking compatibility and environment details.



\- `hostname`

&#x20; - Shows the system hostname.

&#x20; - Helpful for identifying the current machine in a server fleet.



\- `cat /etc/os-release`

&#x20; - Displays the Linux distribution and version.

&#x20; - Useful for confirming the OS before installing software or troubleshooting.



\- `uptime`

&#x20; - Shows how long the system has been running and its load average.

&#x20; - Helps detect high system load.



\- `whoami`

&#x20; - Prints the current logged-in user.

&#x20; - Useful for checking privileges before running admin commands.



\- `id`

&#x20; - Displays user and group IDs.

&#x20; - Helps verify user permissions and group membership.



\- `date`

&#x20; - Shows the current system date and time.

&#x20; - Important for logs, job scheduling, and debugging.



\---



\## 2. File and Directory Management



\- `pwd`

&#x20; - Prints the current working directory.

&#x20; - Useful for confirming your location in the filesystem.



\- `ls`

&#x20; - Lists files and directories.

&#x20; - Basic command for checking directory contents.



\- `ls -l`

&#x20; - Lists detailed file metadata including permissions, ownership, size, and timestamps.

&#x20; - Useful for checking file access and modifications.



\- `ls -la`

&#x20; - Shows hidden files and detailed metadata.

&#x20; - Important for inspecting system configs and hidden files.



\- `cd`

&#x20; - Changes the current directory.

&#x20; - Used to navigate the file system.



\- `mkdir`

&#x20; - Creates a new directory.

&#x20; - Used for creating project, backup, and config folders.



\- `rmdir`

&#x20; - Removes an empty directory.

&#x20; - Used for cleanup.



\- `touch`

&#x20; - Creates an empty file or updates timestamps.

&#x20; - Useful for creating timestamped files and log placeholders.



\- `cp`

&#x20; - Copies files or directories.

&#x20; - Used for backups and duplication.



\- `cp -r`

&#x20; - Recursively copies directories.

&#x20; - Useful for copying application folders.



\- `mv`

&#x20; - Moves or renames files.

&#x20; - Commonly used for deployment and file organization.



\- `rm`

&#x20; - Deletes files.

&#x20; - Must be used carefully in production.



\- `rm -rf`

&#x20; - Force-removes files and directories recursively.

&#x20; - Useful for cleaning build artifacts and temporary directories.



\- `find`

&#x20; - Searches for files and directories by name, date, type, or size.

&#x20; - Essential for locating configs, logs, or scripts.



\- `which`

&#x20; - Shows the path of a command.

&#x20; - Useful for troubleshooting PATH issues.



\- `whereis`

&#x20; - Locates the binary, source, and manual for a command.

&#x20; - Helpful when diagnosing installation issues.



\- `type`

&#x20; - Shows whether a command is an alias, builtin, or executable.

&#x20; - Useful in shell troubleshooting.



\- `stat`

&#x20; - Displays detailed file status.

&#x20; - Helps inspect timestamps and metadata.



\- `file`

&#x20; - Identifies the file type.

&#x20; - Useful for determining if a file is binary, text, executable, or archive.



\- `ln -s`

&#x20; - Creates a symbolic link.

&#x20; - Useful for linking versioned app directories or shared resources.



\- `readlink`

&#x20; - Resolves the target of a symbolic link.

&#x20; - Helps diagnose broken links.



\---



\## 3. File Viewing and Content Reading



\- `cat`

&#x20; - Displays file contents.

&#x20; - Commonly used to read configuration files and scripts.



\- `less`

&#x20; - Views content page by page.

&#x20; - Better for large files and logs than `cat`.



\- `more`

&#x20; - Similar to `less`, but simpler.

&#x20; - Used for reading output in paginated form.



\- `head`

&#x20; - Shows the first lines of a file.

&#x20; - Useful for quick log and config checks.



\- `tail`

&#x20; - Shows the last lines of a file.

&#x20; - Very useful for logs and troubleshooting.



\- `tail -f`

&#x20; - Follows changes in a file in real time.

&#x20; - Essential for monitoring logs live.



\- `grep`

&#x20; - Searches for a pattern in files or command output.

&#x20; - One of the most important commands in DevOps.



\- `grep -i`

&#x20; - Case-insensitive search.

&#x20; - Useful when log entries may vary in capitalization.



\- `grep -v`

&#x20; - Excludes matching lines.

&#x20; - Helps filter out noise from logs.



\- `sed`

&#x20; - Stream editor used for replacing or filtering text.

&#x20; - Common in automation and config processing.



\- `awk`

&#x20; - Processes and extracts formatted data from text.

&#x20; - Frequently used in log parsing and reports.



\- `cut`

&#x20; - Extracts columns or fields from text.

&#x20; - Useful for parsing command output.



\- `wc -l`

&#x20; - Counts lines in a file.

&#x20; - Used to estimate log size or output length.



\- `sort`

&#x20; - Sorts text lines.

&#x20; - Useful for organizing output and comparing data.



\- `uniq`

&#x20; - Removes duplicate adjacent lines.

&#x20; - Used after sorting.



\- `diff`

&#x20; - Shows differences between files.

&#x20; - Important for reviewing config changes.



\- `tee`

&#x20; - Sends output to both the terminal and a file.

&#x20; - Useful in scripts and debugging.



\- `xargs`

&#x20; - Converts input into command arguments.

&#x20; - Very useful in shell automation.



\---



\## 4. Permissions and Ownership



\- `chmod`

&#x20; - Changes file or directory permissions.

&#x20; - Important for securing scripts and files.



\- `chmod +x`

&#x20; - Makes a file executable.

&#x20; - Required for shell scripts.



\- `chown`

&#x20; - Changes file ownership.

&#x20; - Useful for assigning files to correct users or services.



\- `chgrp`

&#x20; - Changes group ownership.

&#x20; - Used in multi-user systems and service access control.



\- `sudo`

&#x20; - Executes a command with root or administrative privileges.

&#x20; - Essential for system administration.



\- `su`

&#x20; - Switches user context.

&#x20; - Used for testing access and privileges.



\- `useradd`

&#x20; - Creates a new user.

&#x20; - Important for provisioning systems.



\- `usermod`

&#x20; - Modifies an existing user.

&#x20; - Used for permission or user property changes.



\- `userdel`

&#x20; - Deletes a user.

&#x20; - Used for cleanup or removing access.



\- `groupadd`

&#x20; - Creates a new group.

&#x20; - Helps organize access control.



\- `passwd`

&#x20; - Sets or changes a user password.

&#x20; - Common admin task.



\- `umask`

&#x20; - Sets default permissions for new files.

&#x20; - Useful for standardizing secure defaults.



\---



\## 5. Process Management



\- `ps`

&#x20; - Displays running processes.

&#x20; - Fundamental for troubleshooting and monitoring.



\- `ps aux`

&#x20; - Shows all processes with detailed information.

&#x20; - Very common in Linux troubleshooting.



\- `top`

&#x20; - Displays real-time CPU, memory, and process usage.

&#x20; - Used for system monitoring.



\- `htop`

&#x20; - Improved interactive version of `top`.

&#x20; - Easier to use for process inspection.



\- `pgrep`

&#x20; - Finds process IDs by name.

&#x20; - Useful in automation and service checks.



\- `pkill`

&#x20; - Kills processes by name.

&#x20; - Used to stop services quickly.



\- `kill`

&#x20; - Sends a signal to a process.

&#x20; - Commonly used to stop a service gracefully.



\- `kill -9`

&#x20; - Force-kills a process.

&#x20; - Last resort when a process is unresponsive.



\- `killall`

&#x20; - Kills all processes matching a command name.

&#x20; - Handy in scripting and service cleanup.



\- `jobs`

&#x20; - Lists jobs running in the shell.

&#x20; - Useful for managing background tasks.



\- `bg`

&#x20; - Puts a job in the background.

&#x20; - Helps continue work without blocking the shell.



\- `fg`

&#x20; - Brings a background job back to the foreground.

&#x20; - Useful for interactive tasks.



\- `nohup`

&#x20; - Runs a command even after the terminal exits.

&#x20; - Useful for long-running jobs and daemons.



\- `nice`

&#x20; - Sets process priority.

&#x20; - Helps manage resource allocation.



\- `renice`

&#x20; - Changes the priority of a running process.

&#x20; - Useful in performance tuning.



\- `lsof`

&#x20; - Lists open files and network sockets.

&#x20; - Helpful in port and process debugging.



\- `fuser`

&#x20; - Identifies which process is using a file or port.

&#x20; - Useful when a service cannot restart due to a port lock.



\---



\## 6. Disk and Filesystem Management



\- `df -h`

&#x20; - Displays disk space usage in human-readable form.

&#x20; - Crucial for checking storage capacity.



\- `du -sh`

&#x20; - Shows the size of a directory.

&#x20; - Useful for locating large folders.



\- `lsblk`

&#x20; - Displays block devices and partitions.

&#x20; - Helps inspect storage configuration.



\- `fdisk -l`

&#x20; - Lists disk partitions.

&#x20; - Used for storage and RAID troubleshooting.



\- `mkfs.ext4`

&#x20; - Creates an ext4 filesystem.

&#x20; - Used when setting up a new disk or partition.



\- `mkfs.xfs`

&#x20; - Creates an XFS filesystem.

&#x20; - Common on Linux servers and enterprise workloads.



\- `mount`

&#x20; - Mounts a filesystem.

&#x20; - Essential for attaching storage volumes.



\- `umount`

&#x20; - Unmounts a mounted filesystem.

&#x20; - Used for maintenance and device removal.



\- `mount -a`

&#x20; - Mounts all configured filesystems from `/etc/fstab`.

&#x20; - Helps restore services after reboot.



\- `blkid`

&#x20; - Shows filesystem UUID and type.

&#x20; - Useful for updating `/etc/fstab`.



\- `free -h`

&#x20; - Shows memory and swap usage in human-readable form.

&#x20; - Important for performance monitoring.



\- `vmstat`

&#x20; - Reports memory, CPU, and I/O activity.

&#x20; - Useful for system performance analysis.



\- `iostat`

&#x20; - Shows CPU and disk I/O statistics.

&#x20; - Helps diagnose storage bottlenecks.



\- `iotop`

&#x20; - Displays I/O usage by process.

&#x20; - Useful for identifying disk-heavy processes.



\---



\## 7. Networking and Connectivity



\- `ip addr`

&#x20; - Shows IP addresses and interface details.

&#x20; - Essential for checking network configuration.



\- `ip route`

&#x20; - Displays routing table information.

&#x20; - Useful in troubleshooting connectivity.



\- `ping`

&#x20; - Tests connectivity to another host.

&#x20; - Basic network troubleshooting tool.



\- `curl`

&#x20; - Transfers data using HTTP/HTTPS.

&#x20; - Used for API calls and website health checks.



\- `curl -I`

&#x20; - Fetches only HTTP headers.

&#x20; - Useful for checking if a service is responding.



\- `wget`

&#x20; - Downloads files from the internet.

&#x20; - Common in automation and deployments.



\- `ssh`

&#x20; - Connects securely to a remote system.

&#x20; - One of the most important commands in DevOps.



\- `scp`

&#x20; - Securely copies files between machines.

&#x20; - Common for server file transfers.



\- `rsync`

&#x20; - Efficiently copies and synchronizes files.

&#x20; - Used for backups and deployments.



\- `ss -tulpn`

&#x20; - Shows listening ports and active sockets.

&#x20; - Very useful for checking running services.



\- `netstat`

&#x20; - Displays network connections and listening sockets.

&#x20; - Traditional network troubleshooting tool.



\- `dig`

&#x20; - Queries DNS records.

&#x20; - Useful when debugging domain resolution issues.



\- `nslookup`

&#x20; - Performs DNS lookups.

&#x20; - Helpful for DNS troubleshooting.



\- `traceroute`

&#x20; - Traces the network path to a destination.

&#x20; - Helps diagnose connectivity and routing problems.



\- `iptables`

&#x20; - Manages firewall rules.

&#x20; - Important for network security.



\- `ufw`

&#x20; - Uncomplicated firewall tool for Ubuntu.

&#x20; - Used to allow or block service access.



\- `firewall-cmd`

&#x20; - Firewall configuration tool on RHEL/CentOS.

&#x20; - Used to manage ports and zones.



\- `nc` or `netcat`

&#x20; - Connects to TCP/UDP ports.

&#x20; - Useful for quick port testing.



\---



\## 8. Services and System Management



\- `systemctl`

&#x20; - Manages systemd services.

&#x20; - Essential for Linux service administration.



\- `systemctl status`

&#x20; - Shows the status of a service.

&#x20; - Common troubleshooting command.



\- `systemctl start`

&#x20; - Starts a service.



\- `systemctl stop`

&#x20; - Stops a service.



\- `systemctl restart`

&#x20; - Restarts a service.



\- `systemctl enable`

&#x20; - Enables a service at boot.



\- `systemctl disable`

&#x20; - Disables a service at boot.



\- `systemctl daemon-reload`

&#x20; - Reloads systemd unit files after changes.



\- `journalctl`

&#x20; - Reads system logs managed by systemd.

&#x20; - Critical for debugging service issues.



\- `journalctl -u service-name`

&#x20; - Shows logs for a specific service.



\- `journalctl -f`

&#x20; - Follows logs in real time.



\- `service`

&#x20; - Starts/stops services in SysV init systems.

&#x20; - Used on older Linux distributions.



\- `crontab`

&#x20; - Manages scheduled jobs.

&#x20; - Used widely in automation and maintenance.



\- `crontab -l`

&#x20; - Lists current cron jobs.



\- `crontab -e`

&#x20; - Edits cron jobs.



\---



\## 9. Logs and Monitoring



\- `dmesg`

&#x20; - Displays kernel messages and hardware events.

&#x20; - Useful for diagnosing boot and hardware issues.



\- `tail -f /var/log/syslog`

&#x20; - Follows system logs in real time.

&#x20; - Key for troubleshooting.



\- `journalctl -xe`

&#x20; - Displays detailed systemd error logs.

&#x20; - Useful for finding the root cause of service failures.



\- `last`

&#x20; - Shows recent login activity.

&#x20; - Helpful for auditing access.



\- `who`

&#x20; - Displays currently logged-in users.

&#x20; - Useful for access verification.



\- `top`

&#x20; - Shows resource usage by process.

&#x20; - Very important in performance analysis.



\- `vmstat`

&#x20; - Reports virtual memory and CPU statistics.

&#x20; - Used for performance checks.



\- `iostat`

&#x20; - Shows disk and CPU I/O statistics.

&#x20; - Useful for diagnosing storage bottlenecks.



\- `sar`

&#x20; - Collects and reports historical system metrics.

&#x20; - Helpful for performance trend analysis.



\---



\## 10. Archive and Compression



\- `tar`

&#x20; - Creates and extracts tar archives.

&#x20; - Common for backup and software packaging.



\- `tar -cvf`

&#x20; - Creates a tar archive.



\- `tar -xvf`

&#x20; - Extracts a tar archive.



\- `tar -czvf`

&#x20; - Creates a gzip-compressed tar archive.



\- `tar -xzvf`

&#x20; - Extracts a gzip-compressed tar archive.



\- `gzip`

&#x20; - Compresses files.

&#x20; - Common for log compression and archive management.



\- `gunzip`

&#x20; - Decompresses gzip files.



\- `zip`

&#x20; - Creates ZIP archives.

&#x20; - Used for packaging files.



\- `unzip`

&#x20; - Extracts ZIP files.



\- `bzip2`

&#x20; - Compresses files using bzip2.

&#x20; - Good for efficient compression.



\---



\## 11. Search and Text Processing



\- `grep`

&#x20; - Searches text patterns.

&#x20; - One of the most useful commands for logs and code.



\- `grep -R`

&#x20; - Recursively searches directories.



\- `grep -n`

&#x20; - Shows line numbers of matches.



\- `sed`

&#x20; - Performs text substitution and pattern-based editing.



\- `awk`

&#x20; - Extracts and formats data from text files.

&#x20; - Essential for parsing logs.



\- `cut`

&#x20; - Extracts specified fields from text.



\- `sort`

&#x20; - Sorts text.



\- `uniq`

&#x20; - Removes duplicate entries.



\- `tr`

&#x20; - Translates or removes characters from text.



\- `wc`

&#x20; - Counts bytes, words, or lines.



\- `find`

&#x20; - Searches directories by criteria such as file name and date.



\- `xargs`

&#x20; - Converts standard input into arguments for another command.



\---



\## 12. Security and Hardening



\- `chmod 600 file`

&#x20; - Restricts file access to the owner only.

&#x20; - Strong security practice.



\- `chmod 700 directory`

&#x20; - Restricts directory access to the user only.



\- `sudo`

&#x20; - Runs commands as root.

&#x20; - Required for many system admin tasks.



\- `su`

&#x20; - Switches to another user.

&#x20; - Used for privilege testing and admin work.



\- `sshd`

&#x20; - OpenSSH daemon for secure remote access.

&#x20; - Essential for Linux servers.



\- `ssh-keygen`

&#x20; - Generates SSH key pairs.

&#x20; - Standard for passwordless secure access.



\- `ssh-copy-id`

&#x20; - Copies the public SSH key to a remote server.

&#x20; - Helps automate secure SSH login.



\- `ufw allow 22`

&#x20; - Allows SSH traffic through the firewall.

&#x20; - Used to secure and expose required ports.



\- `iptables -L`

&#x20; - Lists current firewall rules.

&#x20; - Useful for checking security policies.



\- `openssl`

&#x20; - Creates keys, certificates, and tests TLS.

&#x20; - Important for security configuration.



\---



\## 13. Backup and Restore



\- `cp -a`

&#x20; - Copies files while preserving attributes and structure.

&#x20; - Useful for backups.



\- `rsync -a`

&#x20; - Securely syncs directories while preserving metadata.

&#x20; - Common for backup and deployment tasks.



\- `tar -czf`

&#x20; - Creates compressed backups.

&#x20; - Standard backup method in Linux.



\- `dd`

&#x20; - Copies raw data blocks.

&#x20; - Used for disk cloning and low-level backups.



\- `restorecon`

&#x20; - Restores SELinux context if needed.

&#x20; - Useful in security-sensitive environments.



\---



\## 14. Docker Commands (DevOps Relevant)



\- `docker ps`

&#x20; - Lists running containers.



\- `docker ps -a`

&#x20; - Lists all containers including stopped ones.



\- `docker images`

&#x20; - Lists available container images.



\- `docker pull`

&#x20; - Downloads a Docker image.



\- `docker run`

&#x20; - Starts a container.



\- `docker stop`

&#x20; - Stops a running container.



\- `docker rm`

&#x20; - Removes a container.



\- `docker logs`

&#x20; - Shows logs from a container.



\- `docker exec -it`

&#x20; - Opens an interactive shell inside a running container.



\- `docker build`

&#x20; - Builds an image from a Dockerfile.



\- `docker inspect`

&#x20; - Shows metadata about a container or image.



\- `docker stats`

&#x20; - Displays resource usage of containers.



\---



\## 15. Kubernetes Commands (DevOps Relevant)



\- `kubectl get pods`

&#x20; - Lists running pods.



\- `kubectl get svc`

&#x20; - Lists services.



\- `kubectl logs`

&#x20; - Shows logs for a pod.



\- `kubectl exec -it`

&#x20; - Runs commands inside a pod.



\- `kubectl describe pod`

&#x20; - Shows detailed pod information and events.



\- `kubectl apply -f file.yaml`

&#x20; - Applies Kubernetes configuration.



\- `kubectl get nodes`

&#x20; - Lists cluster nodes.



\- `kubectl get ns`

&#x20; - Lists namespaces.



\---



\## 16. Useful DevOps One-Liners



\- `ps aux --sort=-%mem`

&#x20; - Shows processes sorted by memory usage.



\- `ss -tulpn | grep 8080`

&#x20; - Checks which service is listening on port 8080.



\- `df -h /`

&#x20; - Checks root filesystem usage.



\- `du -sh /\\\* 2>/dev/null | sort -h`

&#x20; - Lists directory sizes in human-readable form.



\- `grep -R "error" /var/log`

&#x20; - Searches logs for errors.



\- `tail -f /var/log/syslog`

&#x20; - Monitors system logs live.



\- `journalctl -u nginx --since "1 hour ago"`

&#x20; - Shows recent Nginx logs.



\- `free -h \\\&\\\& uptime`

&#x20; - Displays memory and uptime.



\---



\## 17. Best Practices for DevOps on Linux



\- Learn command-line basics thoroughly.

\- Practice shell scripting for automation.

\- Always verify file permissions before running scripts.

\- Master log analysis with `grep`, `tail`, and `journalctl`.

\- Use `systemctl` for service management.

\- Be comfortable with SSH, `scp`, and `rsync`.

\- Understand networking, port checks, and DNS.

\- Monitor CPU, memory, disk, and process usage regularly.

\- Use automation and cron jobs for repetitive tasks.

\- Use security best practices for SSH, firewall, and access control.



\---



\## 18. Recommended Learning Order



1\. Basic Linux commands

2\. File and directory management

3\. Users, groups, and permissions

4\. Process management

5\. Disk and filesystem checks

6\. Networking and SSH

7\. Logs and monitoring

8\. Shell scripting

9\. Service management with `systemctl`

10\. Docker and Kubernetes basics



\---



\## 19. Conclusion



Linux is the foundation of DevOps. A DevOps engineer should be confident with Linux command-line tools for administration, automation, monitoring, troubleshooting, networking, security, and deployment tasks. Mastering these commands improves efficiency across server management, cloud operations, CI/CD, and container orchestration.



\---



\## 20. Quick Command Cheat Sheet



\- `ls` — List files

\- `cd` — Change directory

\- `pwd` — Show current directory

\- `cp` — Copy files

\- `mv` — Move/rename files

\- `rm` — Remove files

\- `mkdir` — Create directory

\- `chmod` — Set permissions

\- `chown` — Change ownership

\- `ps` — View processes

\- `kill` — Stop a process

\- `top` — Monitor system usage

\- `df -h` — Check disk space

\- `du -sh` — Check directory size

\- `ping` — Test network connectivity

\- `ssh` — Connect to remote server

\- `scp` — Copy files remotely

\- `curl` — Test HTTP endpoints

\- `tail -f` — Follow log files live

\- `grep` — Search content

\- `systemctl` — Manage services

\- `journalctl` — View logs

\- `tar` — Archive files

\- `rsync` — Sync files efficiently

\- `crontab` — Schedule jobs



