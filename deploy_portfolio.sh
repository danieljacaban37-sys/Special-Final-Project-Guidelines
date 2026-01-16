#!/bin/bash

# Portfolio Website Deployment Script for Ubuntu
# GitHub Repo URL - REPLACE WITH YOUR OWN REPO LINK
REPO_URL="https://github.com/danieljacaban37-sys/Special-Final-Project-Guidelines.git"
# Target directory for website files
TARGET_DIR="/var/www/index.html/portfolio"
# Apache virtual host config file
VHOST_FILE="/etc/apache2/sites-available/portfolio.conf"


# Step 1: Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y


# Step 2: Install and configure Apache if not present
if ! dpkg -l | grep -q apache2; then
    echo "Installing Apache web server..."
    sudo apt install apache2 -y
fi

# Start and enable Apache to run on boot
echo "Starting Apache service..."
sudo systemctl start apache2
sudo systemctl enable apache2


# Step 3: Fetch latest files from GitHub
echo "Fetching website files from GitHub..."
if [ -d "$TARGET_DIR" ]; then
    # If directory exists, pull latest updates
    cd "$TARGET_DIR" || exit
    sudo git pull origin main
else
    # If directory doesn't exist, clone repo
    sudo git clone "$REPO_URL" "$TARGET_DIR"
fi


# Step 4: Configure Apache virtual host
echo "Configuring Apache virtual host..."
sudo tee "$VHOST_FILE" > /dev/null <<EOL
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot $TARGET_DIR
    ServerName portfolio.local  # Optional: For local testing; set DNS if needed

    ErrorLog \${APACHE_LOG_DIR}/portfolio_error.log
    CustomLog \${APACHE_LOG_DIR}/portfolio_access.log combined

    <Directory $TARGET_DIR>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOL

# Enable the new site and disable default site (optional but recommended)
sudo a2ensite portfolio.conf
sudo a2dissite 000-default.conf

# Restart Apache to apply changes
echo "Restarting Apache..."
sudo systemctl restart apache2


echo "Deployment complete! Your portfolio is accessible at http://localhost/portfolio or your server's IP address."
