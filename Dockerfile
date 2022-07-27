FROM openjdk:18-slim-bullseye

RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

RUN mkdir -p server/docker
RUN mkdir plugin
COPY ./server/target/cqf-ruler-server-*.war server/ROOT.war
COPY ./server/docker/ server/docker
RUN chmod u+x -R server/docker
EXPOSE 8443
CMD ["java", "-cp", "server/ROOT.war", "-Dloader.path=WEB-INF/classes,WEB-INF/lib,WEB-INF/lib-provided,plugin", "org.springframework.boot.loader.PropertiesLauncher"]
ENTRYPOINT ["/server/docker/docker-entrypoint.sh"]
