@echo off
set SCRIPT_DIR=%~dp0
set SBT_OPTS=-Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=384M

set SBT_JAR="%SCRIPT_DIR%sbt-launch.jar"

java %JAVA_OPTS% %SBT_OPTS% -jar %SBT_JAR% %*
