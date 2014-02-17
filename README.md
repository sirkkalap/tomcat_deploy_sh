tomcat_deploy_sh
================

Simple robust tomcat stop, deploy, start shell-scripts for CI and development. Maybe production too, if you feel lucky.

* Solves the problem of shutting down Tomcat synchronously. 
* Has a timeout and uses force option to really stop a stuck instance
* Uses netstat / lsof (Darvin) to determine if Tomcat has really been stopped
* Validates the deployment wars using jar -t
* Fails fast and does not try healing spells, chicken bones or suck black magic

*NOTE*

Assumes that `url="http://localhost:${TOMCAT_PORT}/$artifact/ping"` returns heartbeat of the deployed apps (200 OK). ([deploy.sh](deploy.sh) line 71)