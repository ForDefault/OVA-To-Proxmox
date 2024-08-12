import paramiko
import scp
import pathlib
import settings
import sys
from paramiko import SSHClient, ssh_exception, AutoAddPolicy
from scp import SCPClient
from pathlib import Path

class vboxToProxmox:
    def __init__(self, ovaPath, pveIP, pvePort, pveLogin, pvePass, storagePath):
        self.ovaPath = Path(ovaPath)
        self.ovaName = self.ovaPath.name
        self.pveIP = pveIP
        self.pvePort = pvePort
        self.pveLogin = pveLogin
        self.pvePass = pvePass
        self.storagePath = storagePath.rstrip('/') + '/convert'
        self.ssh = SSHClient()
        self.ssh.set_missing_host_key_policy(AutoAddPolicy())
        self.connect()
        self.run()

    def connect(self):
        print("[$] Connecting to the Proxmox Hypervisor...")
        try:
            self.ssh.load_system_host_keys()
            self.ssh.connect(self.pveIP, self.pvePort, self.pveLogin, self.pvePass, timeout=10)
        except ssh_exception.AuthenticationException:
            print("Authentication error, make sure your username and password are correct and allowed to connect via SSH.")
            sys.exit(1)
        except Exception as e:
            print(f"Impossible to connect to the Proxmox hypervisor, make sure the SSH port and IP are correct: {e}")
            sys.exit(1)

    def run(self):
        self.prepareRemoteDirectory()
        self.sendOva()
        self.uploadImportScript()
        self.printCompletionInstructions()

    def prepareRemoteDirectory(self):
        print(f"[$] Creating remote directory: {self.storagePath}")
        self.ssh.exec_command(f'mkdir -p {self.storagePath}')

    def sendOva(self):
        print("[$] Uploading OVA...")
        def progress(filename, size, sent):
            percent_complete = (sent / size) * 100
            sys.stdout.write(f"\rUploading {filename}: {percent_complete:.2f}% complete")
            sys.stdout.flush()
        scp = SCPClient(self.ssh.get_transport(), progress=progress)
        scp.put(str(self.ovaPath), f"{self.storagePath}/{self.ovaName}")
        print("\n[$] OVA uploaded.")

    def uploadImportScript(self):
        print("[$] Uploading import script...")
        script_local_path = "import.sh"
        script_remote_path = f"{self.storagePath}/import.sh"
        scp = SCPClient(self.ssh.get_transport())
        scp.put(script_local_path, script_remote_path)
        self.ssh.exec_command(f"chmod +x {script_remote_path}")
        print("[$] Import script uploaded and permissions set.")

    def printCompletionInstructions(self):
        print("\n[$] To complete the process, execute the following commands on the Proxmox server:")
        print(f"cd {self.storagePath}")
        print("chmod +x import.sh")
        print("./import.sh")

if __name__ == "__main__":
    vbox = vboxToProxmox(
        ovaPath=settings.ovaPath,
        pveIP=settings.ipProxmox,
        pvePort=settings.sshPort,
        pveLogin=settings.loginProxmox,
        pvePass=settings.passwordProxmox,
        storagePath=settings.storagePath
    )
