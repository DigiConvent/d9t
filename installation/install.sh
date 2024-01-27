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

REPO_URL="https://github.com/DigiConvent/d9t.git"

if [ "$#" -ne 1 ]; then 
    echo "No version specified"
    echo "Available versions:\nlatest"
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

curl -L -o https://raw.githubusercontent.com/DigiConvent/d9t/$TAG/installation/digiconvent.service
sudo cp digiconvent.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable digiconvent.service
sudo systemctl start digiconvent.service
sudo systemctl status digiconvent.service
