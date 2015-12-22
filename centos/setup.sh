#!/bin/bash

# Init
FILE="/tmp/out.$$"
GREP="/bin/grep"
#....

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo -e "This script must be run as root" 1>&2
   exit 1

else
    while [ 1 -eq 1 ]; do
      read -p "Setup APM? [y/n] " yn
      case $yn in
          [Yy]* )
            echo -e "Installing Aapche HTTP..."
            yum install -y httpd
            chkconfig httpd on
            service httpd start
          
            echo -e "Installing MariaDB 10.1...."
            echo -e "[mariadb] \nname = MariaDB \nbaseurl = http://yum.mariadb.org/10.1/centos6-amd64 \ngpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB \ngpgcheck=1" > /etc/yum.repos.d/MariaDB.repo
            yum install -y MariaDB-server MariaDB-client
            chkconfig mysql on
            service mysql start
            mysql_secure_installation
         
            echo -e "Installing PHP module...."
            yum install -y php php-mysql
            echo -e "<?php phpinfo(); ?>" > /var/www/html/info.php

            service httpd restart

            break
            ;;

          [Nn]* )
            break
            ;;

          * ) echo -e "Please answer yes or no."
            ;;
      esac
    done
    
    while [ 1 -eq 1 ]; do
      read -p "Setup Java? [y/n] " yn
      case $yn in
          [Yy]* )
            wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
            "http://download.oracle.com/otn-pub/java/jdk/8u60-b27/jre-8u60-linux-x64.rpm"
            yum localinstall jre-8u60-linux-x64.rpm
            rm jdk-8u60-linux-x64.rpm 
         
            alternatives --config java
            echo -e "JAVA_HOME=/opt/jdk1.8.0_60\n" \
                    "JRE_HOME=/opt/jdk1.8.0_60/jre" >> /etc/environment
            echo -e "PATH=\$PATH:/opt/jdk1.8.0_60/bin:/opt/jdk1.8.0_60/jre/bin" >> /etc/profile.d/java.sh
            export JAVA_HOME=/opt/jdk1.8.0_60
            export JRE_HOME=/opt/jdk1.8.0_60/jre
            export PATH=\$PATH:/opt/jdk1.8.0_60/bin:/opt/jdk1.8.0_60/jre/bin

            java -version
            break
            ;;

          [Nn]* )
            break
            ;;

          * ) echo -e "Please answer yes or no."
            ;;
      esac
    done

    while [ 1 -eq 1 ]; do
      read -p "Setup Tomcat? [y/n] " yn
      case $yn in
          [Yy]* )
            echo -e "Installing Tomcat 8.0.30..."
            wget "http://apache.tt.co.kr/tomcat/tomcat-8/v8.0.30/bin/apache-tomcat-8.0.30.tar.gz"
            tar xzf apache-tomcat-8.0.30.tar.gz -C /usr/share/apache-tomcat-8.0.30
            ln -s /usr/share/apache-tomcat-8.0.30 /usr/share/apache-tomcat
            rm -rf apache-tomcat-8.0.30.tar.gz

            echo -e "Configuring....."
            mv /usr/share/apache-tomcat/conf/tomcat-users.xml /usr/share/apache-tomcat/conf/tomcat-users.bak
            echo -e "<?xml version='1.0' encoding='utf-8'?>\n" \
                    "<tomcat-users xmlns=\"http://tomcat.apache.org/xml\"\n" \
                    "    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n" \
                    "    xsi:schemaLocation=\"http://tomcat.apache.org/xml tomcat-users.xsd\"\n" \
                    "    version=\"1.0\">\n" \
                    "    \n" \
                    "    <role rolename=\"manager-gui\"/>\n" \
                    "    <role rolename=\"manager-cui\"/>\n" \
                    "    <user username=\"conectTomcatAdmin\" password=\"tomcat!conect1\" role=\"manager-gui, manager-cui\"/>\n" \
                    "    \n" \
                    "</tomcat-users>" > /usr/share/apache-tomcat/conf/tomcat-users.xml
            echo -e "CATALINA_HOME=/usr/share/apache-tomcat" >> /etc/environment
            cp -a ../common/tomcat /etc/init.d/tomcat
            chmod 755 /etc/init.d/tomcat
            chkconfig tomcat on

            echo -e "Starting..."
            service tomcat start

            break
            ;;
        
          [Nn]* )
            break
            ;;
       
          * )
            echo -e "Please answer yes or no."
            ;;
      esac
    done

    while [ 1 -eq 1 ]; do
      read -p "Setup mod_jk(Apache-Tomcat connector)? [y/n]" yn
      case $yn in
          [Yy]* )
            echo -e "Installing mod_jk..."
            yum install -y httpd-devel
            wget http://mirror.apache-kr.org/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.40-src.tar.gz
            tar zxvf tomcat-connectors-1.2.40-src.tar.gz -C /tmp/tomcat-connectors-1.2.40-src
            /bin/bash /tmp/tomcat-connectors-1.2.40-src/native/configure --with-apxs=/usr/sbin/apxs
            /bin/bash /tmp/tomcat-connectors-1.2.40-src/native/make
            /bin/bash /tmp/tomcat-connectors-1.2.40-src/native/make install
            rm tomcat-connectors-1.2.40-src.tar.gz
            rm -rf /tmp/tomcat-connectors-1.2.40-src

            cp -a ../common/mod_jk.conf /etc/httpd/conf.d/mod_jk.conf
            cp -a ../common/workers.properties /etc/httpd/conf/workers.properties
            cp -a ../common/uriworkermap.properties /etc/httpd/conf/uriworkermap.properties
          
            break
            ;;

          [Nn]* )
            break
            ;;

          * )
            echo -e "Please answer yes or no."
            ;;
      esac
    done
fi
#
