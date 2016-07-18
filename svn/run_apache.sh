#!/bin/bash

username=admin
password=admin
repo_list=repo

#Set from ENV Variables
if [[ ! -z $USERNAME ]]; then
    username=$USERNAME
fi

if [[ ! -z $PASSWORD ]]; then
    password=$PASSWORD
fi

if [[ ! -z $REPO_LIST ]]; then
    repo_list=$REPO_LIST
fi

#Create svnpasswd file with username and password
htpasswd -bcm /etc/svnpasswd $username $password

IFS=',' read -r -a repos <<< "${repo_list}"

for repo in "${repos[@]}"; do
    svnadmin create /svn/repos/$repo
    chown -R www-data:www-data /svn/repos/$repo
    cp /etc/apache2/sites-available/repo_template.conf /etc/apache2/sites-available/$repo.conf
    a2ensite $repo
done

rm /etc/apache2/sites-available/repo_template.conf


/etc/init.d/apache2 start && \
tail -F /var/log/apache2/*log
