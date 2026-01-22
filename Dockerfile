# File: Dockerfile
# Mô t?: File c?u hình Docker d? build image Spring Boot
# Ch?c nang: T?o image Docker t? source code Java,
#            cài d?t dependencies, compile code, build JAR file,
#            ch?y ?ng d?ng Spring Boot trong container

# Stage 1: Build the application using Maven and Java 21
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY bizflow-app/pom.xml bizflow-app/pom.xml
COPY promotion-service/pom.xml promotion-service/pom.xml
COPY bizflow-app/src bizflow-app/src
COPY promotion-service/src promotion-service/src
RUN mvn -pl bizflow-app -am -DskipTests package

# Stage 2: Create the final, lightweight image with the application JAR
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/bizflow-app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
