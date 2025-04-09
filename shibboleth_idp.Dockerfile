FROM tomcat:latest

ENV VERSION="5.1.4"

ENV SHIB_IDP_FOLDER="shibboleth-identity-provider-$VERSION"
ENV SHIB_IDP_ARCHIVE="$SHIB_IDP_FOLDER.tar.gz"
ENV HOME_FOLDER="/usr/local/tomcat"

RUN java -version
RUN wget https://shibboleth.net/downloads/identity-provider/latest/$SHIB_IDP_ARCHIVE && \
    tar -xzvf $SHIB_IDP_ARCHIVE && \
    cd $SHIB_IDP_FOLDER && \
    pwd

ENV SHIB_IDP_CONFIG_FILE="/tmp/shib_idp_install_config"
RUN echo "idp.noprompt=true" >> $SHIB_IDP_CONFIG_FILE
RUN echo 'idp.target.dir=/opt/shibboleth-idp' >> $SHIB_IDP_CONFIG_FILE
RUN echo 'idp.entityID=runai-entity' >> $SHIB_IDP_CONFIG_FILE
RUN echo 'idp.host.name=blablabla.com' >> $SHIB_IDP_CONFIG_FILE
RUN echo 'idp.scope=blablabla' >> $SHIB_IDP_CONFIG_FILE

RUN cd $SHIB_IDP_FOLDER && ./bin/install.sh --propertyFile $SHIB_IDP_CONFIG_FILE

# 1) Edit idp.properties: 
#    The main configuration file is idp.properties, located in the conf directory of your IdP installation. Update the file with your specific settings, such as the entity ID and scope.
#
# 2) Configure metadata:
#    Ensure your IdP metadata is accessible. Place your metadata file in the metadata directory and update the path in metadata-providers.xml.
#
# 3) Set up credentials:
#    Configure your IdP's credentials for signing and encryption. Update the credentials.xml file with paths to your keystore and private key.

RUN cp /opt/shibboleth-idp/war/idp.war /usr/local/tomcat/webapps/sh
