package rd.issue.kafka_conn;


import org.apache.flink.table.api.*;
import org.apache.flink.table.api.TableEnvironment;

import java.util.Map;

public class TableApiJob {

    public static void main(String[] args) {

        EnvironmentSettings settings = EnvironmentSettings
                .newInstance()
                .inStreamingMode()
                .build();

        TableEnvironment tEnv = TableEnvironment.create(settings);

        Map<String, String> config = Map.of(
                "kafka.bootstrap.servers", "kafka:29092",
                "kafka.group_id", "my-id");

        String createTableInput = """                
                CREATE TABLE inputTbl (
                  `name` STRING
                ) WITH (
                  'connector' = 'kafka',
                  'topic' = 'input_topic',
                  'properties.bootstrap.servers' = '${kafka.bootstrap.servers}',
                  'properties.group.id' = '${kafka.group_id}',
                  'scan.startup.mode' = 'earliest-offset',
                  'value.format' = 'json'
                );
                """;
        String createTableOutput = """
                CREATE TABLE outputTbl (
                  `name` STRING NOT NULL,
                  source STRING NOT NULL
                ) WITH (
                  'connector' = 'kafka',
                  'sink.transactional-id-prefix' = 'outputTbl',
                  'topic' = 'output_topic',
                  'properties.bootstrap.servers' = '${kafka.bootstrap.servers}',
                  'value.format' = 'json'
                );
                """;
        String insert1 = """
                INSERT INTO outputTbl
                SELECT `name`, 'query1'
                FROM inputTbl;
                """;
        String insert2 = """
                INSERT INTO outputTbl
                SELECT `name`, 'query2'
                FROM inputTbl;
                """;

        tEnv.executeSql(replaceTokens(createTableInput, config));
        tEnv.executeSql(replaceTokens(createTableOutput, config));
        var tSet = tEnv.createStatementSet();
        tSet.addInsertSql(insert1);
        tSet.addInsertSql(insert2);
        var x = tSet.execute();
    }


    public static String replaceTokens(String query, Map<String, String> settings) {
        return settings.entrySet().stream()
                .reduce(query, (acc, entry) -> acc.replace("${%s}".formatted(entry.getKey()), entry.getValue()), (s1, s2) -> s1);
    }

}
