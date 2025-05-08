#!/bin/sh

UPLOAD_SDA_JOB_MAX_ATTEMPTS=${UPLOAD_SDA_JOB_MAX_ATTEMPTS:-60}
UPLOAD_SDA_JOB_INTERVAL=${UPLOAD_SDA_JOB_INTERVAL:-1}
UPLOAD_SDA_JOB_START_DELAY=${UPLOAD_SDA_JOB_START_DELAY:-5}

handle_abort() {
  echo "Abort signal received. Cleaning up..."
  # Add any cleanup commands here
  exit 1
}

trap 'handle_abort' INT TERM

upload_job_jar() {
  JOB_JAR="/test-job.jar"
  # shellcheck disable=SC2089
  SUCCESS_STRING='"status":"success"'
  NR_ATTEMPT=0

  echo "Uploading ${JOB_JAR}..."

  sleep "${UPLOAD_SDA_JOB_START_DELAY}"
  while [ "${NR_ATTEMPT}" -lt "${UPLOAD_SDA_JOB_MAX_ATTEMPTS}" ]; do
    NR_ATTEMPT=$((NR_ATTEMPT + 1))
    echo " . Uploading ${JOB_JAR} (attempt ${NR_ATTEMPT})"
    RESPONSE=$(curl -s -H "Expect:" -F "jarfile=@${JOB_JAR}" http://jobmanager:8081/jars/upload)

    case "${RESPONSE}" in
      *${SUCCESS_STRING}*)
        echo ${RESPONSE}
        JAR_ID=$(echo "${RESPONSE}" | sed -n 's/.*\/flink-web-upload\/\([^"]*\).*/\1/p')
        echo "...Uploading ${JOB_JAR} succeeded with attempt ${NR_ATTEMPT} (jar_id:${JAR_ID})"
        export JAR_ID
        break
        ;;
    esac
    sleep "${UPLOAD_SDA_JOB_INTERVAL}"
  done
  if [ "${NR_ATTEMPT}" -eq "${UPLOAD_SDA_JOB_MAX_ATTEMPTS}" ]; then
    echo  "...Uploading  ${JOB_JAR} failed (tried ${NR_ATTEMPT} times)"
    exit 1
  fi
}

start_job() {
  echo "Starting Job..."
  RESPONSE=$(curl -s -X POST http://jobmanager:8081/jars/${JAR_ID}/run \
   -H "Content-Type: application/json" \
   -d '{
   "entryClass": "rd.issue.kafka_conn.TableApiJob",
   "parallelism": 1
   }')

   echo "Job started: ${RESPONSE}"
}

upload_job_jar
start_job
