# Issue with Duplicate transactionalIdPrefix in Flink 2.0 Kafka Sinks

I'm encountering an issue with Flink 2.0 when using the Table API.
In previous versions (1.18/1.19/1.20), I was able to create a Flink job with the following setup:

* One Kafka topic-based input table
* One Kafka topic-based output table
* One statement set with two insert statements, both reading from the input and writing to the output table

However, with Flink 2.0, the JobManager generates the following error:

> java.lang.IllegalStateException: Found duplicate transactionalIdPrefix for multiple Kafka sinks: null. 
> Transactional id prefixes need to be unique. You may experience memory leaks without fixing this.

Is this expected behavior in Flink 2.0, or should it still be possible to use the same setup without encountering this error?

To reproduce the error, you can run the example bash script `./build-and-start-job.sh`.
It will compile the job and start a Docker environment running the job.
It also opens up the Flink dashboard, where you can find the failing job (after a few seconds).

Additionally, when you use `1.20` or `1.19` as an argument to the script, the job runs successfully.

