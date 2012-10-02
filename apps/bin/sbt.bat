@echo off
set SCRIPT_DIR=%~dp0

set SBT_OPTS=-Xms512M -Xmx1792M -Xss1M
set SBT_OPTS=%SBT_OPTS% -XX:MaxPermSize=200M -XX:ReservedCodeCacheSize=60M
set SBT_OPTS=%SBT_OPTS% -XX:+CMSClassUnloadingEnabled -XX:-UseGCOverheadLimit

set SBT_JAR="%SCRIPT_DIR%sbt-launch-0.12.1.jar"

java %JAVA_OPTS% %SBT_OPTS% -jar %SBT_JAR% %*
