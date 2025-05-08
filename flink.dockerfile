ARG FLINK_VERSION

FROM flink:${FLINK_VERSION}

ARG KAFKA_CONNECTOR_VERSION

RUN cd $FLINK_HOME/lib; \
    curl -v -O "https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-kafka/${KAFKA_CONNECTOR_VERSION}/flink-sql-connector-kafka-${KAFKA_CONNECTOR_VERSION}.jar"; \
    chown flink:flink flink-sql-connector-kafka-${KAFKA_CONNECTOR_VERSION}.jar
