#!/bin/bash
# Init
FILE="/tmp/out.$$"
GREP="/bin/grep"
#....
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
else
    read -p "Setup APM? [y/n] " yn
    case $yn in
        [Yy]* )
          yum install -y httpd
          service httpd start
          
          echo "[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.0/centos6-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1" > /etc/yum.repos.d/MariaDB.repo
          yum install -y MariaDB-server MariaDB-client
          service mysql start
          mysql_secure_installation
          
          yum install -y php php-mysql
          
          echo '<?php phpinfo(); ?>' > /var/www/html/info.php

          service httpd restart
          chkconfig httpd on
          chkconfig mysql on
          break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
    
    read -p "Setup Java? [y/n] " yn
    case $yn in
        [Yy]* )
          wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.tar.gz"
          tar xzf jdk-8u45-linux-x64.tar.gz -C /opt/jdk1.8.0_45/bin/java
          rm -rf jdk-8u45-linux-x64.tar.gz
          
          alternatives --install /usr/bin/java java /opt/jdk1.8.0_45/bin/java 2
          alternatives --config java
          alternatives --install /usr/bin/jar jar /opt/jdk1.8.0_45/bin/jar 2
          alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_45/bin/javac 2
          alternatives --set jar /opt/jdk1.8.0_45/bin/jar
          alternatives --set javac /opt/jdk1.8.0_45/bin/javac 
          java -version
          
          echo "JAVA_HOME=/opt/jdk1.8.0_45" >> /etc/environment
          echo "JRE_HOME=/opt/jdk1.8.0_45/jre" >> /etc/environment
          echo "PATH=\$PATH:/opt/jdk1.8.0_45/bin:/opt/jdk1.8.0_45/jre/bin" >> /etc/profile.d/java.sh
          break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac

    read -p "Setup Tomcat? [y/n] " yn
    case $yn in
        [Yy]* )
          wget http://mirror.apache-kr.org/tomcat/tomcat-8/v8.0.23/bin/apache-tomcat-8.0.23.tar.gz
          tar xzf apache-tomcat-8.0.23.tar.gz -C /usr/share/apache-tomcat-8.0.23
          ln -s /usr/share/apache-tomcat-8.0.23 /usr/share/apache-tomcat
          rm -rf apache-tomcat-8.0.23.tar.gz
          mv /usr/share/apache-tomcat/conf/tomcat-users.xml /usr/share/apache-tomcat/conf/tomcat-users.bak
          echo "<?xml version='1.0' encoding='utf-8'?>
<tomcat-users xmlns=\"http://tomcat.apache.org/xml\"
              xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
              xsi:schemaLocation=\"http://tomcat.apache.org/xml tomcat-users.xsd\"
              version=\"1.0\">

  <role rolename=\"manager-gui\"/>
  <role rolename=\"manager-cui\"/>
  <user username=\"conectTomcatAdmin\" password=\"tomcat!conect1\" role=\"manager-gui, manager-cui\"/>
</tomcat-users>" > /usr/share/apache-tomcat/conf/tomcat-users.xml
          echo "CATALINA_HOME=/usr/share/apache-tomcat" >> /etc/environment
          cp -a tomcat /etc/init.d/tomcat
          chmod 755 /etc/init.d/tomcat
          service tomcat start
          chkconfig tomcat on
          break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac

    read -p "Setup mod_jk(Apache-Tomcat connector)? [y/n]" yn
    case $yn in
        [Yy]* )
          yum install -y httpd-devel
          wget http://mirror.apache-kr.org/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.40-src.tar.gz
          tar zxvf tomcat-connectors-1.2.40-src.tar.gz -C /tmp/tomcat-connectors-1.2.40-src
          /bin/bash /tmp/tomcat-connectors-1.2.40-src/native/configure --with-apxs=/usr/sbin/apxs
          /bin/bash /tmp/tomcat-connectors-1.2.40-src/native/make
          /bin/bash /tmp/tomcat-connectors-1.2.40-src/native/make install
          rm tomcat-connectors-1.2.40-src.tar.gz
          rm -rf /tmp/tomcat-connectors-1.2.40-src

          cp -a mod_jk.conf /etc/httpd/conf.d/mod_jk.conf
          cp -a workers.properties /etc/httpd/conf/workers.properties
          cp -a uriworkermap.properties /etc/httpd/conf/uriworkermap.properties
          break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
fi
#
