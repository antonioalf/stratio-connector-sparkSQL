# Install sparkSQL connector

export MAVEN_OPTS="-XX:MaxPermSize=512m -Xmx3072m"

git clone https://github.com/Stratio/hbase.git

cd hbase/

mvn clean install -DskipTests

cd ..

git clone https://github.com/Stratio/spark-cassandra-connector.git

cd spark-cassandra-connector/

git checkout SPARKC-112

sbt publishM2

cd ..

git clone https://github.com/Stratio/spark-mongodb.git

cd spark-mongodb/

mvn clean install -DskipTests

cd ..

## Installing sparkSQL connector
mvn clean install -DskipTests

cd connector-sparkSQL/

## Cleaning repositories
cd ..	

rm -rf hbase/ spark-cassandra-connector/ spark-mongodb/
