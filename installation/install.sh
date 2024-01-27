#!/bin/bash
USERNAME="digiconvent"

# Check if the user exists
if ! id "$USERNAME" &>/dev/null; then
    echo "Step 1: User $USERNAME does not exist, creating..."
    sudo useradd -m "$USERNAME"
    # You can also set a password for the user if required using sudo passwd $USERNAME
else
    echo "User $USERNAME already exists, skipping step 1..."
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing jq..."
    sudo apt-get update
    sudo apt-get install -y jq
else
    echo "jq is already installed."
fi

# Check if unzip is installed
if ! command -v unzip &> /dev/null; then
    echo "unzip is not installed. Installing unzip..."
    sudo apt-get update
    sudo apt-get install -y unzip
else
    echo "unzip is already installed."
fi

REPO_URL="https://github.com/DigiConvent/d9t.git"

if [ "$#" -ne 1 ]; then 
    echo "No version specified"
    echo -e "Available versions:\nlatest"
    git ls-remote --tags $REPO_URL | awk -F'/' '{print $3}' | sed '/^\s*$/d'
    exit 1
fi

if [ "$1" == "latest" ]; then
    TAG=$(git ls-remote --tags --sort="v:refname" $REPO_URL | tail -n1 | sed 's/.*\///')
else
    TAG=$1
fi

echo "Using version $TAG"

RELEASE_DATA=$(curl -s "https://api.github.com/repos/digiconvent/d9t/releases/tags/$TAG")
ASSET_URL=$(echo "$RELEASE_DATA" | jq -r '.assets[0].browser_download_url')
echo $ASSET_URL
if [ -z "$ASSET_URL" ]; then
    echo "No assets found for release $TAG"
    exit 1
fi

cd /home/digiconvent/
curl -L -o "release.zip" "$ASSET_URL"
rm -rf release/
unzip release.zip
rm release.zip

# store binaries in the correct folders
rm -rf /opt/digiconvent/

mkdir /opt/digiconvent/
mv release/server_linux /opt/digiconvent/
mv release/server_m1 /opt/digiconvent/
chown -R digiconvent:digiconvent /opt/digiconvent/

curl -L -o digiconvent.service https://raw.githubusercontent.com/DigiConvent/d9t/main/installation/digiconvent.service
sudo cp digiconvent.service /etc/systemd/
sudo systemctl daemon-reload
sudo systemctl enable digiconvent.service
sudo systemctl start digiconvent.service
sudo systemctl status digiconvent.service
