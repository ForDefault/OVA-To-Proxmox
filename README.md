# OVA-To-Proxmox

# Under Construction - Still Testing

Quick method to transfer an ova quickly and generate a VM in a, mostly, automated way.


-- I wanted to make this fully automated but could not figure out how to entirely do that. 

```
echo ">>>>>>>>>> Mount Paths For Directory Storage <<<<<<<<<<"
df -h | grep -Ev '^Filesystem|tmpfs|udev|/run|/sys|/dev/shm|/dev/loop|/boot/efi|/dev/fuse'

```
# #1  Copy this command into Proxmox cli and select the Mounted Storage Path you want to use
```
PUTHERE=$(whoami) && \
REPO_URL="https://github.com/ForDefault/OVA-To-Proxmox.git" && \
REPO_NAME=$(basename $REPO_URL .git) && \
DEST_DIR="/home/$PUTHERE/$REPO_NAME" && \
if [ -d "$DEST_DIR" ]; then \
  rm -rf "$DEST_DIR"; \
fi && \
git clone $REPO_URL "$DEST_DIR" && \
cd "$DEST_DIR" && \
chmod +x start.sh main.py import.sh && \
./start.sh

```

# #2  Run this command on your PC containing the OVA - follow the prompts

# #3  After the transfer is complete copy the result command and go back to the Proxmox cli

# #4  Run the result command and your VM should be created and available to use shortly
