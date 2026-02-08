# Tomcat 10.1 Deployment Guide

## Prerequisites
- **Java**: JDK 17 installed and configured (`JAVA_HOME`).
- **Tomcat**: Apache Tomcat 10.1.x installed.

## 1. Prepare Spring Boot for WAR Deployment

Modify `pom.xml` to change packaging to `war`:

```xml
<packaging>war</packaging>
```

Add `spring-boot-starter-tomcat` dependency with `provided` scope:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-tomcat</artifactId>
    <scope>provided</scope>
</dependency>
```

Modify the main application class to extend `SpringBootServletInitializer`:

```java
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

public class ClientApiApplication extends SpringBootServletInitializer {
    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(ClientApiApplication.class);
    }
    // ... main method
}
```

## 2. Build the WAR file

Run the following command in the `backend` directory:

```bash
mvn clean package
```

This will generate a `.war` file in the `target` directory (e.g., `client-api-0.0.1-SNAPSHOT.war`).

## 3. Deploy to Tomcat

1.  Copy the generated WAR file to the `webapps` directory of your Tomcat installation.
    -   Example: `C:\Program Files\Apache Software Foundation\Tomcat 10.1\webapps\`
2.  Rename the file to `api.war` if you want the context path to be `/api`.
    -   Alternatively, keep the name and configure the context path in `server.xml` or let it default to the filename.
3.  Start Tomcat:
    -   `bin\startup.bat` (Windows)
    -   `bin/startup.sh` (Linux)

## 4. Verification

Access the API health check or a test endpoint:
`https://localhost:8080/api/health` (assuming you deployed as `api.war`)

## Notes for Tomcat 10 (Jakarta EE 9/10)
Spring Boot 3.x is compatible with Tomcat 10.1 as it uses Jakarta EE 10 (jakarta.* namespace). Ensure you are NOT using older libraries that rely on `javax.*` namespace without migration.
