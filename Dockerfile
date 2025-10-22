FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app

COPY . .

RUN mvn clean package -DskipTests

FROM tomcat:8.5-jdk17-temurin
LABEL maintainer="siddhussoft136"

RUN apt-get update && \
    apt-get install -y net-tools tree vim && \
    rm -rf /var/lib/apt/lists/* && apt-get clean && apt-get purge

RUN echo 'export JAVA_OPTS="-Dapp.env=staging"' > /usr/local/tomcat/bin/setenv.sh

COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/demo.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
