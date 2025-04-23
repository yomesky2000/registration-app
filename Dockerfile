# Use official Tomcat base image
FROM tomcat:latest

# Clean default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR file and rename to ROOT.war
COPY webapp.war /usr/local/tomcat/webapps/ROOT.war
