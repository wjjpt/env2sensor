# env2sensor

script for query data openweathermap api, normalize and inject into kafka topic

# BUILDING

- Build docker image:
  * git clone https://github.com/wjjpt/env2sensor.git
  * cd src/
  * docker build -t wjjpt/envsensor2k .

# EXECUTING

- Execute app using docker image:

`docker run --env KAFKA_BROKER=X.X.X.X --env KAFKA_PORT=9092 --env KAFKA_TOPIC='envsensor' -ti wjjpt/envsensor2k`

