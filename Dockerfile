# ---------- Stage 1: Build the Java web app ----------
FROM maven:3.9.6-eclipse-temurin-17 AS builder

# Set working directory
WORKDIR /app

# Copy everything to the container
COPY . .

# Build the application (skip tests for faster CI)
RUN mvn clean package -DskipTests

# ---------- Stage 2: Create Tomcat runtime image ----------
FROM tomcat:8.5-jdk17-temurin
LABEL maintainer="siddhussoft136"

# Install optional debugging tools
RUN apt-get update && \
    apt-get install -y net-tools tree vim && \
    rm -rf /var/lib/apt/lists/* && apt-get clean && apt-get purge

# Set environment variable for Java options
RUN echo 'export JAVA_OPTS="-Dapp.env=staging"' > /usr/local/tomcat/bin/setenv.sh

# Copy the built WAR file from builder stage into Tomcat webapps
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/demo.war

# Expose the Tomcat port
EXPOSE 8080

# Start Tomcat server
CMD ["catalina.sh", "run"]
