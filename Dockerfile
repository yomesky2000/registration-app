FROM tomcat:latest

# Clean default apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy your WAR file from the correct directory
COPY webapp/target/webapp.war /usr/local/tomcat/webapps/ROOT.war

