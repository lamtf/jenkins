FROM alpine:3.11

RUN apk add --no-cache openjdk8 ttf-dejavu

RUN adduser -D -g '' jenkins

ENV JENKINS_HOME=/home/jenkins/.jenkins

ADD http://mirrors.jenkins.io/war-stable/latest/jenkins.war /opt/jenkins.war

USER jenkins

RUN echo "## Running Jenkins ## " && \
sh -c "java -jar /opt/jenkins.war > /dev/null 2>&1 &" && \
sleep 30s && \
echo "## Installing Jenkins Packages ##" && \
java -jar $JENKINS_HOME/war/WEB-INF/jenkins-cli.jar -auth admin:$(cat $JENKINS_HOME/secrets/initialAdminPassword) -s http://127.0.0.1:8080/ install-plugin publish-over-ssh credentials  credentials-binding git git-parameter build-timeout publish-over workflow-aggregator branch-api config-file-provider email-ext pam-auth && \
sleep 10s && \
echo "## Ending ##" && \
kill -9 $(ps x | grep [j]ava | xargs | cut -d ' ' -f1)

RUN apk add --no-cache nodejs

RUN apk add --no-cache tzdata && \
cp /usr/share/zoneinfo/America/Bahia /etc/localtime && \
echo "America/Bahia" >  /etc/timezone && \
apk del --no-cache tzdata

ENTRYPOINT ["java", "-jar", "/opt/jenkins.war"]
