# OVA-To-Proxmox

# Under Construction - Still Testing

Quick method to transfer an ova quickly and generate a VM in a, mostly, automated way.


Note: This process is not fully automated, but these steps will guide you through it as seamlessly as possible.

# #1  Copy and run the following command in the Proxmox CLI (web browser is easy) to simplify selecting the Mounted Storage Path you want to use:

```
echo ">>>>>>>>>> Mount Paths For Directory Storage <<<<<<<<<<"
df -h | grep -Ev '^Filesystem|tmpfs|udev|/run|/sys|/dev/shm|/dev/loop|/boot/efi|/dev/fuse'
```
I would leave open the web browser containing the possible Directory Paths to use.


# #2  Run the following command on your PC containing the OVA file. Follow the prompts to complete the process:
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
# #3  After the transfer is complete, the script will generate a command for you. Copy the result command and return to the Proxmox CLI.

# #4  Execute the Final Command anywhere in Proxmox. The rest of the VM creation is automated. 
