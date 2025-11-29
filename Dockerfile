FROM eclipse-temurin:21-jdk-alpine AS build
ARG APP_VERSION=5.0.0
LABEL Name="Java SpringBoot Demopipe App" Version=${APP_VERSION}
LABEL org.opencontainers.image.source="https://github.com/obsidionz/build-test-contain"
WORKDIR /build 

# Copy Maven wrapper
COPY .mvn ./.mvn
COPY mvnw ./mvnw

# Copy project files
COPY pom.xml .
COPY src ./src

# Make wrapper executable and build runtime stage
RUN chmod +x ./mvnw && \
    ./mvnw -ntp clean package -Drevision=${APP_VERSION} -DskipTests -Dmaven.test.skip=true -Dcheckstyle.skip=true && \
    mv target/demopipe-*.jar target/demopipe.jar

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /build/target/demopipe.jar .
# healthcheck incase container app needs restart 
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "demopipe.jar"]