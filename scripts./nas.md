To create a guide for adding a NAS mount on your system, I'll provide a detailed step-by-step instruction list below. This guide will include variables for the IP address, mount location, mount path, and credentials file. It will also cover setting the correct file permissions, checking and adding a user group, assigning the group to users, and finally, printing the mount command and restarting the necessary services.

### Guide to Add NAS Mount

###  Notes:
- Replace `your_nas_username` and `your_nas_password` with your actual NAS credentials.
- Replace `your_username` with the username(s) of the user(s) you want to grant access to the NAS.
- You can add multiple users to the NAS group by repeating the `usermod` command with different usernames.
- Ensure the NAS share path (`SHARE_PATH`) and mount point (`MOUNT_POINT`) are correctly specified according to your NAS settings and desired mount location on your system.


#### Prerequisites:
- Ensure `cifs-utils` is installed on your system. If not, install it using:
  ```bash
  sudo apt update && sudo apt install cifs-utils
  ```

#### Step 1: Define Variables
First, define the necessary variables. Replace the placeholder values with your actual data.
```bash
NAS_IP="192.168.1.251"            # IP address of your NAS
```
```bash
MOUNT_POINT="/mnt/nas"           # Local mount point
```
```bash
SHARE_PATH="03_PI2"              # Path of the shared folder on the NAS
```
```bash
CRED_FILE="/etc/nas-credentials" # Path to the credentials file
```
```bash
GROUP_NAME="nas"                 # Group name for accessing the NAS
```

#### Step 2: Create Credentials File
Create a credentials file to store your NAS username and password.
```bash
sudo touch "$CRED_FILE"
```
```bash
echo "username=your_nas_username" | sudo tee "$CRED_FILE"
```
```bash
echo "password=your_nas_password" | sudo tee -a "$CRED_FILE"
```
```bash
sudo chmod 600 "$CRED_FILE"
```

#### Step 3: Set Up Group and Permissions
Check if the group exists and add it if necessary. Then, add users to this group.
```bash
if ! getent group "$GROUP_NAME" > /dev/null; then
    sudo groupadd "$GROUP_NAME"
fi
```
```bash
sudo usermod -a -G "$GROUP_NAME" your_username
```

#### Step 4: Create Mount Point
Create the directory that will serve as the mount point for the NAS share.
```bash
sudo mkdir -p "$MOUNT_POINT"
sudo chown "$USER":"$GROUP_NAME" "$MOUNT_POINT"
sudo chmod 0770 "$MOUNT_POINT"
```

#### Step 5: Update `/etc/fstab`
Add the NAS mount to `/etc/fstab` to ensure it's mounted automatically at boot.
```bash
echo "//${NAS_IP}/${SHARE_PATH} ${MOUNT_POINT} cifs credentials=${CRED_FILE},iocharset=utf8,gid=$(getent group "$GROUP_NAME" | cut -d: -f3),file_mode=0770,dir_mode=0770,nofail,noauto,x-systemd.automount 0 0" | sudo tee -a /etc/fstab
```

#### Step 6: Mount the Share and Restart Services
Mount the share and enable it to mount automatically on boot.
```bash
sudo mount -a
```
```bash
sudo systemctl daemon-reload
```

#### Step 7: reboot
Ensure the NAS is properly mounted to your specified mount point.
```bash
sudo reboot
```

#### Step 8: Verify the Mount
Ensure the NAS is properly mounted to your specified mount point.
```bash
mount | grep "$MOUNT_POINT"
```
