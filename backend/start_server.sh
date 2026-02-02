#!/bin/bash

# Attempt to find JDK 17
if [ -x "/usr/libexec/java_home" ]; then
    JAVA_HOME_17=$(/usr/libexec/java_home -v 17 2>/dev/null)
    if [ ! -z "$JAVA_HOME_17" ]; then
        export JAVA_HOME="$JAVA_HOME_17"
        echo "✅ Using configured JDK 17: $JAVA_HOME"
    else
        echo "⚠️ JDK 17 not found via /usr/libexec/java_home. Attempting to use current JAVA_HOME."
    fi
fi

# Print current Java version for debugging
echo "Checking Java version..."
java -version

echo "--------------------------------------"
echo "🚀 Starting Spring Boot Application..."
echo "--------------------------------------"

mvn spring-boot:run
