FROM flyway/flyway:10-alpine

# Download IBM DB2 JDBC driver
RUN apk add --no-cache curl && \
    mkdir -p /flyway/drivers && \
    curl -L https://repo1.maven.org/maven2/com/ibm/db2/jcc/11.5.9.0/jcc-11.5.9.0.jar \
         -o /flyway/drivers/jcc.jar && \
    apk del curl

# The driver will be available to Flyway
ENTRYPOINT ["flyway"]
CMD ["-?"]