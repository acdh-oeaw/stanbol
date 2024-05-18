#FROM tomcat:9-jdk8-temurin
FROM tomcat:8.5-jdk8-temurin-jammy
###
# Set environment variables
###

ENV JAVA_OPTS="-Dlog4j2.formatMsgNoLookups=true -Xms1G -Xmx4G -XX:MaxHeapFreeRatio=20 -XX:MinHeapFreeRatio=10 -XX:GCTimeRatio=20" \
    USER=user \
    USER_HOME=/home/user \
    TERM=xterm \
    TZ='Europe/Vienna' \
    STANBOL_TAG=apache-stanbol-1.0.0

RUN groupadd --gid 1000 user && useradd --gid 1000 --uid 1000 -d / user && echo "user:$6$04SIq7OY$7PT2WujGKsr6013IByauNo0tYLj/fperYRMC4nrsbODc9z.cnxqXDRkAmh8anwDwKctRUTiGhuoeali4JoeW8/:16231:0:99999:7:::" >> /etc/shadow

# Configure Tomcat to work on port 8443

COPY server.xml $CATALINA_HOME/conf/server.xml

###
# Install dependencies and software
###

RUN apt-get update && apt-get upgrade -y && apt-get install -y openjdk-8-jdk nano wget unzip vim maven git sudo gosu locales && \
    apt-get clean && \
###
# Configure TERM that can work nice with nano
###
    export TERM=xterm && \
###
# Preapare home dir for building stanbol.war
###
    mkdir -p $USER_HOME/.m2 && \
    usermod -d $USER_HOME/ $USER && \
###
# Configure sudo
###
    echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
###
# Configure server time
###
    echo $TZ > /etc/timezone && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    locale-gen en_US.UTF-8 && \
###
#  Downlaod latest Stanbol and build war file
###
    cd $USER_HOME && git clone https://github.com/apache/stanbol.git && \
    cd $USER_HOME/stanbol && \
    git checkout tags/$STANBOL_TAG && \
    chown -R $USER:$USER  $USER_HOME && \
    cd $USER_HOME/stanbol && \
    sed -i "s|<stanbol.port>8080</stanbol.port>|<stanbol.port>8443</stanbol.port>|g" $USER_HOME/stanbol/launchers/full-war/pom.xml && \
    sudo -HEu $USER mvn clean install -Dmaven.test.skip   

###
# HTTP Over SSL
###
RUN mkdir "$CATALINA_HOME/keystore" && \
    keytool  -genkey -noprompt -trustcacerts -keyalg RSA -alias tomcat -dname  "CN=ACDH-CH Tech, OU=ACDH, O=OEAW, L=Vienna, ST=Vienna, C=AT" -keypass changeme -keystore "$CATALINA_HOME/keystore/my_keystore" -storepass changeme && \
###
# Deploy Stanbol
###
    cp $USER_HOME/stanbol/launchers/full-war/target/stanbol.war $CATALINA_HOME/webapps/ && \
    rm -fR $USER_HOME/stanbol $USER_HOME/.m && \
    mkdir -p $CATALINA_HOME/stanbol && \
###
# Create entrypoint script
###
    touch /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh && \
    echo "#!/bin/bash" >> /docker-entrypoint.sh && \
    echo "chown -R $USER:$USER $CATALINA_HOME" >> /docker-entrypoint.sh && \
    echo "sudo -HEu $USER sh $CATALINA_HOME/bin/catalina.sh run" >> /docker-entrypoint.sh 

VOLUME $CATALINA_HOME/webapps $CATALINA_HOME/stanbol $CATALINA_HOME/logs

EXPOSE 8443

ENTRYPOINT ["/docker-entrypoint.sh"]
