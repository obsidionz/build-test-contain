#
# Compile, build and package as single 'fat' JAR with Maven
#
FROM eclipse-temurin:21-jdk-alpine AS build
ARG APP_VERSION=1.0.0
LABEL Name="Java SpringBoot Demo App" Version=${APP_VERSION}
LABEL org.opencontainers.image.source = "https://github.com/obsidionz/build-test-contain"
WORKDIR /build 

# Copy Maven files - only if you have the wrapper
# COPY .mvn ./.mvn
# COPY mvnw ./mvnw

# Copy project files
COPY pom.xml .
COPY src ./src

# Install Maven and build (since you don't have mvnw)
RUN apk add --no-cache maven && \
    mvn -ntp clean package -Drevision=${APP_VERSION} -DskipTests -Dmaven.test.skip=true -Dcheckstyle.skip=true

# Rename the JAR to a consistent name
RUN mv target/demopipe-*.jar target/demopipe.jar

#
# Runtime image is just JRE + the fat JAR
#
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Copy the JAR from build stage
COPY --from=build /build/target/demopipe.jar .

# Add health check for actuator
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "demopipe.jar"]