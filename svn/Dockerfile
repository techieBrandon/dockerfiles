FROM wso2/wso2base:latest
MAINTAINER dev@wso2.org

RUN apt-get install subversion apache2 libapache2-svn apache2-utils -y
RUN mkdir -p /svn/repos
COPY repo_template.conf /etc/apache2/sites-available/
COPY run_apache.sh /var/www/
RUN chmod 755 /var/www/run_apache.sh

EXPOSE 80

ENTRYPOINT ["/var/www/run_apache.sh"]