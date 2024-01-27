#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "./setup_database.sh <db_password>"
fi

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update
sudo apt install postgresql-16
sudo service postgresql start


# Creating a new role
sudo -u postgres psql -c "CREATE ROLE d9t WITH LOGIN PASSWORD '$1';"

# Altering the role to allow database creation
sudo -u postgres psql -c "ALTER ROLE d9t CREATEDB;"

# Creating a new database
sudo -u postgres createdb -O your_username your_dbname
