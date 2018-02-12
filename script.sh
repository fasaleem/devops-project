#!/bin/bash -x
#HDP 2.6 installation
#echo "ambari.hdp" > /etc/hostname
#useradd ambari
#echo "ambari"|passwd --stdin ambari
#usermod -aG wheel ambari
#change hostname/ip in /etc/ambari-agent/conf/ambari-agent.ini at line no. 62
groupadd testing
groupadd dev
echo -e "tpatel\ndokiran\nrmohanty\nrkanth\ndan\njchen\ndsaini\nkdonupala\nmdhabale\nndindi\ntsethi" > /tmp/name
for i in `cat /tmp/name`; do useradd -g testing -G dev $i ; done
for i in `cat /tmp/name`; do echo "-phlydev"|passwd --stdin $i ; done
sed -i.bak 's/^#\s*\(%wheel\s*ALL=(ALL)\s*NOPASSWD:\s*ALL\)/\1/' /etc/sudoers
sed -i.bak 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i.bak 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i.bak 's/PermitRootLogin  forced-commands-only/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl restart sshd
yum install mysql-connector-java* ntp vim lynx lsof wget git -y
systemctl stop firewalld
systemctl disable firewalld
sed -i.bak 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
sed -i.bak 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
systemctl start ntpd
systemctl enable ntpd
sestatus
systemctl status firewalld
wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
rpm -ivh mysql-community-release-el7-5.noarch.rpm
yum install mysql-server -y
systemctl start mysqld
systemctl enable mysqld
echo -e "\nn\ny\nroot\nroot\ny\nn\ny\ny" | /usr/bin/mysql_secure_installation
mysqladmin -u root password root
mysql -uroot -proot -e "create database ambari";
mysql -uroot -proot -e "create database hive";
mysql -uroot -proot -e "create database oozie";
mysql -uroot -proot -e "create user ambari@'%' identified by 'bigdata'";
mysql -uroot -proot -e "create user hive@'%' identified by 'bigdata'";
mysql -uroot -proot -e "create user oozie@'%' identified by 'bigdata'";
mysql -uroot -proot -e "grant all privileges on *.* to ambari@'%' identified by 'bigdata' with grant option";
mysql -uroot -proot -e "grant all privileges on *.* to hive@'%' identified by 'bigdata' with grant option";
mysql -uroot -proot -e "grant all privileges on *.* to oozie@'%' identified by 'bigdata' with grant option";
mysql -uroot -proot -e "grant all privileges on *.* to root@'%' identified by 'root' with grant option";
mysql -uroot -proot -e "commit";
wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.5.1.0/ambari.repo -O /etc/yum.repos.d/ambari.repo
yum install ambari-server -y
yum install ambari-agent -y
echo -e "\nn\n1\ny\ny\n3\n\n\n\n\n\ny" | ambari-server setup
mysql -uroot -proot ambari < /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql
ambari-server start
ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar
wget http://public-repo-1.hortonworks.com/HDF/centos6/3.x/updates/3.0.0.0/tars/hdf_ambari_mp/hdf-ambari-mpack-3.0.0.0-453.tar.gz
ambari-server install-mpack --mpack=hdf-ambari-mpack-3.0.0.0-453.tar.gz --verbose
sed -i.bak 's/localhost/10.248.12.249/g' /etc/ambari-agent/conf/ambari-agent.ini
ambari-server restart
ambari-agent start
#git config --global url."https://".insteadOf git://
#git clone git://github.com/devstructure/blueprint.git
#cd blueprint/
#git submodule update --init
#make && sudo make install
#sleep 5
#echo "Rebooting the system"
#reboot
#1st need to setup cluster and then try out below
#To create blueprint from live servrer, execute below.
#curl -H "X-Requested-By: ambari" -X GET -u admin:admin http://ip-10-248-12-249.ec2.internal:8080/api/v1/clusters/HDPNIFI?format=blueprint > cluster_configuration.json
#If blueprint is available then execute below. Make sure cluster_configuration.json and hostmapping.json files are available on server.
#Also do required hostname/ip changes on both files
#curl -H "X-Requested-By: ambari" -X POST -u admin:admin http://ip-10-248-12-249.ec2.internal:8080/api/v1/blueprints/single-node-hdp-cluster -d @cluster_configuration.json
#curl -H "X-Requested-By: ambari" -X POST -u admin:admin http://ip-10-248-12-249.ec2.internal:8080/api/v1/clusters/HDPNIFI -d @hostmapping.json
