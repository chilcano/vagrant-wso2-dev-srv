# Deploy WSO2 C-APP (*.car files) from Maven

Here an useful document explaining how to deploy/undeploy WSO2 C-Apps (car files) from Maven using `maven-car-deploy-plugin`: 
https://docs.wso2.com/display/DVS371/Deploying+and+Debugging#DeployingandDebugging-DeployingaC-ApptomultipleserversusingtheMavenplug-in

Well, I have created a WSO2 Multi-maven project ready to be deployed from Maven in the WSO2 ESB-front-layer and the WSO2 ESB-back-layer.
This simple WSO2 project implements an `Echo API` and includes a set of Pass Through Proxies, APIs, Endpoints and Sequence Templates. 
In the next days this Project will be improved, now let me explain how to build and deploy it properly using Maven.

__1) Configure Maven properly__
If you want deploy the car file to Maven repsitory, then you will need to configure your `.m2/conf/settings.xml` with the correct repositories. In my case, I am using Apache Archiva 2.2.0 (http://archiva.apache.org) and this is my `settings.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" 
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">

<!-- localRepository
   | The path to the local repository maven will use to store artifacts.
   |
   | Default: ${user.home}/.m2/repository
  <localRepository>/Users/Chilcano/2maven-repo</localRepository>
  -->

  <pluginGroups>
  </pluginGroups>

  <proxies>
  </proxies>

  <servers>
    <!-- User created from Archiva web console -->
    <server>
      <id>my.internal</id>
      <username>chilcano</username>
      <password>chilcano1</password>
    </server>   
    <server>
      <id>my.snapshots</id>
      <username>chilcano</username>
      <password>chilcano1</password>
    </server>
  </servers>

  <mirrors>
    <!-- This config will create a mirror of 'central' repo -->
    <mirror>
      <id>my.internal</id>
      <url>http://localhost:8080/repository/internal/</url>
      <mirrorOf>central</mirrorOf>
    </mirror>
    <mirror>
      <id>my.snapshots</id>
      <url>http://localhost:8080/repository/snapshots/</url>
      <mirrorOf>snapshots</mirrorOf>
    </mirror>
  </mirrors>
 
  <profiles>
    <!-- Two repositories added (internal releases and snapshots) -->
    <profile>
      <id>default</id>
      <activation>
        <activeByDefault>true</activeByDefault>
      </activation>
      <repositories>
        <repository>
          <id>internal</id>
          <url>http://localhost:8080/repository/internal/</url>
          <releases>
            <enabled>true</enabled>
          </releases>
          <snapshots>
            <enabled>false</enabled>
          </snapshots>
        </repository>
        <repository>
          <id>snapshots</id>
          <url>http://localhost:8080/repository/snapshots/</url>
          <releases>
            <enabled>false</enabled>
          </releases>
          <snapshots>
            <enabled>true</enabled>
          </snapshots>
        </repository>
      </repositories>
    </profile>
  </profiles>

</settings>
```

__2) Configure your Parent POM file of your C-App Project__

In this case, our pom.xml is located under `~/1github-repo/box-vagrant-wso2-dev-srv/_src/wso2-pattern01-echoapi/pattern01-parent-echoapi/` where `~/1github-repo/box-vagrant-wso2-dev-srv/` is the directory where this Vagrant Box repo was downloaded.

Basically, this pom.xml has been configured following the instructions of above URL (https://docs.wso2.com/display/DVS371/Deploying+and+Debugging#DeployingandDebugging-DeployingaC-ApptomultipleserversusingtheMavenplug-in).


__3) Using Maven to build, deploy and undeploy WSO2 C-App Project__


Download the Project sample from my GitHub repository:
```bash
$ git clone https://github.com/chilcano/wso2-ei-patterns.git
```

Go to your Project `Echo API` directory (`wso2-ei-patterns/pattern01-echoapi/pattern01-parent-echoapi/`):
```bash
$ cd ~/1github-repo/wso2-ei-patterns/pattern01-echoapi/pattern01-parent-echoapi/ 
```

Build It:
```bash
$ mvn clean install
```

Deploy it in server and repository (remote WSO2 ESB servers and Maven repository):
```bash
$ mvn clean deploy -Dmaven.car.deploy.skip=false -Dmaven.deploy.skip=false -Dmaven.wagon.http.ssl.insecure=true -Dmaven.car.deploy.operation=deploy
```

To Undeploy in both (remote WSO2 ESB servers and Maven repository):
```bash
$ mvn clean deploy -Dmaven.car.deploy.skip=false -Dmaven.deploy.skip=false -Dmaven.wagon.http.ssl.insecure=true -Dmaven.car.deploy.operation=deploy
```

If `-Dmaven.deploy.skip=false` is used, then use this `-Dmaven.wagon.http.ssl.insecure=true`, because It avoids the below error when deploying or undeploying.

```bash
...
[INFO] --- maven-car-deploy-plugin:1.1.0:deploy-car (default-deploy-car) @ pattern01-echoapi ---
[INFO] Deploying to Server...
[INFO] TSPath=/Users/Chilcano/1github-repo/box-vagrant-wso2-dev-srv/_mnt_wso2esb01a/repository/resources/security/wso2carbon.jks
[INFO] TSPWD=wso2carbon
[INFO] TSType=JKS
[INFO] Server URL=https://localhost:9449
[INFO] UserName=admin
[INFO] Password=admin
[INFO] Operation=undeploy
log4j:WARN No appenders could be found for logger (org.apache.axis2.description.AxisOperation).
log4j:WARN Please initialize the log4j system properly.
[ERROR] Deleting pattern01-echoapi_1.0.0.car to https://localhost:9449 Failed.
org.apache.axis2.AxisFault: Connection has been shutdown: javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
	at org.apache.axis2.AxisFault.makeFault(AxisFault.java:430)
	at org.apache.axis2.transport.http.SOAPMessageFormatter.writeTo(SOAPMessageFormatter.java:78)
	at org.apache.axis2.transport.http.AxisRequestEntity.writeRequest(AxisRequestEntity.java:84)
...
	at org.codehaus.plexus.classworlds.launcher.Launcher.launch(Launcher.java:229)
	at org.codehaus.plexus.classworlds.launcher.Launcher.mainWithExitCode(Launcher.java:415)
	at org.codehaus.plexus.classworlds.launcher.Launcher.main(Launcher.java:356)
Caused by: com.ctc.wstx.exc.WstxIOException: Connection has been shutdown: javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
```

__4) Check if the WSO2 C-App was deployed__

Just check the WSO2 logs or verify from Carbon Web Admin Console if all artifact were deployed.

