FROM tomcat:latest

ENV VERSION="5.1.4"

ENV SHIB_IDP_FOLDER="shibboleth-identity-provider-$VERSION"
ENV SHIB_IDP_ARCHIVE="$SHIB_IDP_FOLDER.tar.gz"

RUN apt update && apt install -y vim

RUN java -version
RUN wget https://shibboleth.net/downloads/identity-provider/latest/$SHIB_IDP_ARCHIVE && \
    tar -xzvf $SHIB_IDP_ARCHIVE

ENV SHIB_IDP_CONFIG_FILE="/tmp/shib_idp_install_config"
RUN echo 'idp.noprompt=true' >> $SHIB_IDP_CONFIG_FILE
RUN echo 'idp.target.dir=/opt/shibboleth-idp' >> $SHIB_IDP_CONFIG_FILE
RUN echo 'idp.entityID=runai-entity-id-test' >> $SHIB_IDP_CONFIG_FILE
RUN echo 'idp.host.name=sdsc-upgrade-lab.runailabs-cs.com' >> $SHIB_IDP_CONFIG_FILE
RUN echo 'idp.scope=runai-test-instance' >> $SHIB_IDP_CONFIG_FILE
# ldap data connector configuration
RUN echo 'idp.attribute.resolver.LDAP.ldapURL=ldap://openldap.runai.svc.cluster.local:389' >> $SHIB_IDP_CONFIG_FILE
RUN echo 'idp.attribute.resolver.LDAP.baseDN=dc=acme,dc=zzz' >> $SHIB_IDP_CONFIG_FILE
RUN echo 'idp.attribute.resolver.LDAP.bindDN=cn=admin,dc=acme,dc=zzz' >> $SHIB_IDP_CONFIG_FILE
RUN echo 'idp.attribute.resolver.LDAP.bindDNCredential=admin' >> $SHIB_IDP_CONFIG_FILE
RUN echo 'idp.attribute.resolver.LDAP.useStartTLS=false' >> $SHIB_IDP_CONFIG_FILE

RUN cd $SHIB_IDP_FOLDER && ./bin/install.sh --propertyFile $SHIB_IDP_CONFIG_FILE

# 1) Edit idp.properties: 
#    The main configuration file is idp.properties, located in the conf directory of your IdP installation. Update the file with your specific settings, such as the entity ID and scope.
#
# 2) Configure metadata:
#    Ensure your IdP metadata is accessible. Place your metadata file in the metadata directory and update the path in metadata-providers.xml.
#
# 3) Set up credentials:
#    Configure your IdP's credentials for signing and encryption. Update the credentials.xml file with paths to your keystore and private key.

RUN sed -i 's/\.level = .*/\.level = FINEST/' $CATALINA_HOME/conf/logging.properties

RUN cp /opt/shibboleth-idp/war/idp.war $CATALINA_HOME/webapps/idp.war
CMD bash $CATALINA_HOME/bin/catalina.sh run