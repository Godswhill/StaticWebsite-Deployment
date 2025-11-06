# Static Website Deployment on Microsoft Azure (Automated with Bash)

### Author: **Godswill Eshiet**

### Project: *Cloud Computing Individual Project*

---

## Overview

This project automates the **deployment of a static website to Microsoft Azure** using a **Bash script** and **Azure CLI**.
Instead of manually creating cloud resources through the Azure Portal, the script provisions everything — from networking and security to web server configuration — in one command.

The script demonstrates the use of **Infrastructure as Code (IaC)** concepts for efficient, consistent, and repeatable cloud deployments.

---

## Objective

Deploy a **static website** (HTML/CSS) onto **Microsoft Azure** using **automation scripting**.

---

## Tasks Completed

1. Created a **Resource Group**, **Virtual Network**, **Subnet**, and **Network Security Group (NSG)** using Azure CLI.
2. Deployed a **Linux Virtual Machine (Ubuntu 22.04)** automatically using a Bash script.
3. Installed and configured the **NGINX web server** using a cloud-init file.
4. Copied local static website files to the VM’s web root directory (`/var/www/html`).
5. Configured **inbound firewall rules** for SSH (22), HTTP (80), and HTTPS (443).
6. Version-controlled all files using **Git and GitHub**.

---

## Architecture Overview

```
Local Machine
   |
   | (runs Bash script using Azure CLI)
   ↓
Azure Resource Group
 ├── Virtual Network (VNet)
 │    └── Subnet (Web Subnet)
 ├── Network Security Group (NSG)
 │    ├── Allow SSH (22)
 │    ├── Allow HTTP (80)
 │    └── Allow HTTPS (443)
 └── Ubuntu VM (with NGINX)
       ├── Cloud-init installs NGINX
       ├── Website files uploaded via SCP
       └── Hosted at /var/www/html
```

---

## Prerequisites

Before running the script, make sure you have:

1. **Azure CLI** installed
2. Logged in to Azure:

   ```bash
   az login
   ```
3. Your **static website files** ready in a local folder.
4. Linux or macOS environment (or Gitbash on Windows).

---

## How the Script Works

The Bash script (`capstone.sh`) performs the following steps:

1. **Validates input:** Checks if a local website folder is provided.
2. **Verifies Azure CLI installation.**
3. **Creates resources**: Resource Group, Virtual Network, Subnet, and NSG.
4. **Sets up security rules**: Opens ports 22, 80, and 443.
5. **Creates an Ubuntu VM** with a cloud-init script that installs NGINX automatically.
6. **Waits** for the VM to initialize.
7. **Copies local website files** to the VM using `scp`.
8. **Moves them into the NGINX web root** and restarts the web server.
9. Displays the **public IP address** to access the deployed site.

---

## Script Usage

Make the script executable:

```bash
chmod +x capstone.sh
```

Run the script with your local website folder as an argument:

```bash
./capstone.sh /path/to/your/local/website
```

Example:

```bash
./capstone.sh ~/Documents/my-website
```

Once completed, you’ll see an output like:

```
Deployment complete!
Visit your website at: http://<Public-IP>
```

Open that IP in your browser to view your deployed site.

---

## Clean Up (Optional)

To delete all Azure resources and avoid extra costs:

```bash
az group delete -n Godswill_Eshiet-static-site --yes --no-wait
```

---

## Repository Structure

```
 static-website-deployment
 ├── capstone.sh             # Bash automation script
 ├── README.md               # Project documentation
 ├── /website                # Your local website files
 └── /screenshots            # (Optional) Screenshots for your report
```

---

## Key Technologies

* **Microsoft Azure**
* **Azure CLI**
* **Bash Scripting**
* **NGINX Web Server**
* **Cloud-init Automation**
* **Git & GitHub**

---

## Learning Outcomes

* Gained hands-on experience with **cloud infrastructure automation**.
* Understood **Azure networking concepts** (VNets, Subnets, NSGs).
* Practiced **secure VM deployment** using SSH keys.
* Learned how to **automate web hosting** using Bash and NGINX.
* Implemented **Infrastructure as Code (IaC)** best practices.

---

## Repository Link

[**GitHub Repository**](https://github.com/Godswhill/StaticWebsite-Deployment)


---

## Conclusion

This project successfully demonstrates the automation of a **static website deployment to Azure** using a simple Bash script. It combines networking, security, and web server configuration into a single streamlined workflow — a key skill for modern **DevOps and cloud engineers**.

---

## Author

**Godswill Eshiet**
B.Tech (Applied Geology) | Cloud Computing Enthusiast
[willz2you@gmail.com](mailto:willz2you@gmail.com)
[LinkedIn](https://www.linkedin.com/in/godswill-eshiet-5242249a/)

---
