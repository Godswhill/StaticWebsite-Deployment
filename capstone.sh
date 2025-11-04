#!/usr/bin/env bash
set -euo pipefail


# Godswill Eshiet Project – Static Website Deployment on Azure

# 1. Creates RG, VNet, Subnet, NSG (with inbound 22/80/443)
# 2. Deploys Ubuntu VM
# 3. Installs NGINX
# 4. Copies your local website into /var/www/html/


# ---------- CONFIGURE VARIABLES ----------
LOCATION="westus"
RG_NAME="Godswill_Eshiet-static-site"
VNET_NAME="vnet-Godswill_Eshiet"
SUBNET_NAME="Godswill_Eshiet-subnet-web"
NSG_NAME="nsg-Godswill_Eshiet"
VM_NAME="vm-Godswill_Eshiet"
PUBLIC_IP_NAME="${VM_NAME}-ip"
ADMIN_USER="eshiet"
VM_SIZE="Standard_B1s"
IMAGE="Ubuntu2204"
SSH_KEY_PATH="$HOME/.ssh/id_rsa.pub"
TAGS="Godswill_Eshiet"

# Website folder passed as first argument
LOCAL_WEBSITE_PATH="${1:-}"
if [ -z "$LOCAL_WEBSITE_PATH" ]; then
  echo "Usage: $0 /path/to/your/local/website"
  exit 1
fi
if [ ! -d "$LOCAL_WEBSITE_PATH" ]; then
  echo "Directory '$LOCAL_WEBSITE_PATH' not found."
  exit 1
fi

# ---------- CHECK AZURE CLI ----------
if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI not installed. Please install and run 'az login'."
  exit 1
fi

echo "Creating resource group..."
az group create -n "$RG_NAME" -l "$LOCATION" --tags $TAGS --output none

echo "Creating virtual network and subnet..."
az network vnet create \
  -g "$RG_NAME" -n "$VNET_NAME" \
  --address-prefix 10.0.0.0/16 \
  --subnet-name "$SUBNET_NAME" --subnet-prefix 10.0.1.0/24 \
  --output none

echo "Creating NSG and rules..."
az network nsg create -g "$RG_NAME" -n "$NSG_NAME" --output none
az network nsg rule create -g "$RG_NAME" --nsg-name "$NSG_NAME" -n AllowSSH --priority 1000 \
  --access Allow --protocol Tcp --direction Inbound --destination-port-ranges 22 --output none
az network nsg rule create -g "$RG_NAME" --nsg-name "$NSG_NAME" -n AllowHTTP --priority 1010 \
  --access Allow --protocol Tcp --direction Inbound --destination-port-ranges 80 --output none
az network nsg rule create -g "$RG_NAME" --nsg-name "$NSG_NAME" -n AllowHTTPS --priority 1020 \
  --access Allow --protocol Tcp --direction Inbound --destination-port-ranges 443 --output none

echo "Associating NSG with subnet..."
az network vnet subnet update \
  -g "$RG_NAME" --vnet-name "$VNET_NAME" --name "$SUBNET_NAME" \
  --network-security-group "$NSG_NAME" --output none

# ---------- CLOUD INIT (installs NGINX) ----------
CLOUD_INIT_FILE="/tmp/cloud-init-$VM_NAME.yml"
cat > "$CLOUD_INIT_FILE" <<'EOF'
#cloud-config
package_update: true
package_upgrade: false
packages:
  - nginx
runcmd:
  - systemctl enable nginx
  - systemctl start nginx
EOF

# ---------- CREATE VM ----------
echo "Creating Linux VM..."
az vm create \
  -g "$RG_NAME" -n "$VM_NAME" \
  --image "$IMAGE" \
  --size "$VM_SIZE" \
  --admin-username "$ADMIN_USER" \
  --ssh-key-values "$SSH_KEY_PATH" \
  --vnet-name "$VNET_NAME" \
  --subnet "$SUBNET_NAME" \
  --nsg "$NSG_NAME" \
  --public-ip-address "$PUBLIC_IP_NAME" \
  --custom-data "$CLOUD_INIT_FILE" \
  --tags $TAGS \
  --output none

PUBLIC_IP=$(az network public-ip show -g "$RG_NAME" -n "$PUBLIC_IP_NAME" --query "ipAddress" -o tsv)
echo "VM created with Public IP: $PUBLIC_IP"

# ---------- WAIT FOR VM BOOT ----------
echo "Waiting 40s for VM to initialize NGINX..."
sleep 40

# ---------- COPY LOCAL WEBSITE ----------
echo "Copying local website files to VM..."
scp -o StrictHostKeyChecking=no -r "$LOCAL_WEBSITE_PATH"/* ${ADMIN_USER}@${PUBLIC_IP}:/tmp/

echo "Moving files to NGINX web root..."
ssh -o StrictHostKeyChecking=no ${ADMIN_USER}@${PUBLIC_IP} <<'SSHCMDS'
sudo rm -rf /var/www/html/*
sudo mv /tmp/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html
sudo systemctl restart nginx
SSHCMDS

# ---------- DONE ----------
echo "Deployment complete!"
echo "Visit your website at: http://${PUBLIC_IP}"
echo
echo "To delete all resources later, run:"
echo "az group delete -n $RG_NAME --yes --no-wait"
# to run and dont forget to change the permission of the script using chmod +x capstone.sh before executing it.