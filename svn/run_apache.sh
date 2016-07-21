#!/bin/bash
# ------------------------------------------------------------------------
#
# Copyright 2016 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

# ------------------------------------------------------------------------

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
