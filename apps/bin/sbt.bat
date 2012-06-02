@echo off
set SCRIPT_DIR=%~dp0
java -Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=384M -jar %JAVA_OPTS% "%SCRIPT_DIR%sbt-launch.jar" %*
