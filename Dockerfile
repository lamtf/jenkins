FROM alpine:3.11

# Install Jenkins and it's dependences

RUN apk add --no-cache openjdk8 ttf-dejavu

RUN adduser -D -g '' jenkins

ENV JENKINS_HOME /home/jenkins

ADD http://mirrors.jenkins.io/war-stable/latest/jenkins.war /opt/
#ADD jenkins.war /opt/

RUN chmod a+r /opt/jenkins.war

USER jenkins

# Install some default Jenkins packages

RUN echo "## Running Jenkins ##" && \
sh -c "java -jar /opt/jenkins.war > /dev/null 2>&1 &" && \
jenkins_count=$(ls -1 /home/jenkins | wc -l) && \
while [ $jenkins_count -lt 17 ] ; do sleep 2; jenkins_count=$(ls -1 /home/jenkins | wc -l); echo "$jenkins_count of 17 creating jenkins folders..."; done && \
while [ ! -f $JENKINS_HOME/secrets/initialAdminPassword ]; do; echo "waiting for initialAdminPassword file" sleep 2; done && \
java -jar $JENKINS_HOME/war/WEB-INF/jenkins-cli.jar -auth admin:$(cat $JENKINS_HOME/secrets/initialAdminPassword) -s http://127.0.0.1:8080/ install-plugin credentials-binding \
publish-over-ssh credentials \
credentials-binding \
git git-parameter \
build-timeout \
publish-over \
workflow-aggregator \
branch-api \
config-file-provider \
email-ext \
pam-auth && \
kill -9 $(ps x | grep [j]ava | xargs | cut -d ' ' -f1)

USER root
# Install lamtf Dependences

RUN apk add --no-cache nodejs

USER jenkins

ENTRYPOINT ["java", "-jar", "/opt/jenkins.war"]
