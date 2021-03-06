First Steps
***********

Table of Contents
=================

-  `Before you start <#before-you-start>`__

   -  `Prerequisites <#prerequisites>`__
   -  `Configuration <#configuration>`__

-  `Registering the catalog and the
   collection <#registering-the-catalog-and-the-collection>`__

   -  `Step 1: Creating the catalog <#step-1-creating-the-catalog>`__
   -  `Step 2: Registering the collection <#step-2-registering-the-collection>`__
   -  `Step 3: Select FROM <#step-3-select-from>`__

-  `Querying Data <#querying-data>`__

-  `Where to go from here <#where-to-go-from-here>`__

Before you start
================

Prerequisites
-------------
- You need to install sbt and maven.

- `Stratio Crossdata <https://github.com/Stratio/crossdata>`__ is needed in order to interact with this connector.

- An existing and deployed `Hive metastore <ConfMetastore.html/>`__.

- Build a SparkSQLConnector executable and run it following this `guide <about.html>`__.

Configuration
-------------

In the Stratio Crossdata Shell we need configure the datastore cluster.

::

    >  ATTACH CLUSTER hdfsCluster ON DATASTORE hdfs WITH OPTIONS {'hosts': '', 'path': '/path', 'highavailability' : ''};

The output must be similar to:

::

      Result: QID: 82926b1e-2f72-463f-8164-98969c352d40
      Cluster attached successfully

Now we run the connector.

The last step is to attach the connector to the cluster created before.

::

      >  ATTACH CONNECTOR hdfsconnector TO hdfsCluster  WITH OPTIONS {'DefaultLimit' : <limitSize>};

The output must be:

::

    CONNECTOR attached successfully

To ensure that the connector is online we can execute the Stratio Crossdata
Shell command:

::

      > describe connectors;

And the output must show a message similar to:

::

    Connector: connector.sparkSQLConnector  ONLINE  []  [datastore.hdfs]    akka.tcp://CrossdataServerCluster@127.0.0.1:46646/user/ConnectorActor/

Registering the catalog and the collection
===========================================

Step 1: Creating the catalog
----------------------------

Now we will create the catalog and the table which we will use later in
the next steps.

To create the catalog we must execute.

::

        > CREATE CATALOG metastore;

The output must be:

::

    CATALOG created successfully

Step 2: Registering the collection
----------------------------------

To register the table, remember it has to be registered in our Hive metastore (this will provide Spark SQL
enough info to find out which datasource and some other options are needed to retrieve data).
Having assured that, we must execute the next command.

::

      > REGISTER TABLE metastore.students ON CLUSTER hdfsCluster (id int PRIMARY KEY, name text, age int, enrolled boolean);

In case the table was not previously registered in Hive metastore, we can register it by adding associated Datasource parameters.
::

      > REGISTER TABLE metastore.students ON CLUSTER hdfsCluster (id int PRIMARY KEY, name text, age int, enrolled boolean) WITH {'path' : 'my-table-path'};

And the output must show something like:

::

    TABLE created successfully

Querying Data
=============

Step 3: Select FROM
----------------------------------

-  `Before you start <#before-you-start>`__

   -  `Prerequisites <#prerequisites>`__
   -  `Configuration <#configuration>`__

All we have to do now is launching our query in the Stratio Crossdata Shell.

::

      >  SELECT * FROM metastore.students;

Now we execute a set of queries and we will show the expected results.

Select all
----------------------------------

::

     > SELECT * FROM metastore.students;

      Partial result: true
      ----------------------------------
      | age | name     | id | enrolled |
      ----------------------------------
      | 16  | Jhon     | 1  | true     |
      | 20  | Eva      | 2  | true     |
      | 18  | Lucie    | 3  | true     |
      | 16  | Cole     | 4  | true     |
      | 17  | Finn     | 5  | false    |
      | 21  | Violet   | 6  | false    |
      | 18  | Beatrice | 7  | true     |
      | 16  | Henry    | 8  | false    |
      | 17  | Tommy    | 9  | true     |
      | 20  | Betty    | 10 | true     |
      ----------------------------------

Select with primary key
~~~~~~~~~~~~~~~~~~~~~~~

::

      > SELECT name, enrolled FROM metastore.students where id = 1;

      Partial result: true
      -------------------
      | name | enrolled |
      -------------------
      | Jhon | true     |
      -------------------

Select with alias
~~~~~~~~~~~~~~~~~

::

       >  SELECT name as the_name, enrolled  as is_enrolled FROM metastore.students;

      Partial result: true
      --------------------------
      | the_name | is_enrolled |
      --------------------------
      | Jhon     | true        |
      | Eva      | true        |
      | Lucie    | true        |
      | Cole     | true        |
      | Finn     | false       |
      | Violet   | false       |
      | Beatrice | true        |
      | Henry    | false       |
      | Tommy    | true        |
      | Betty    | true        |
    --------------------------

Select with limit
~~~~~~~~~~~~~~~~~

::

      >  SELECT * FROM metastore.students LIMIT 3;

      Partial result: true
      -------------------------------
      | age | name  | id | enrolled |
      -------------------------------
      | 16  | Jhon  | 1  | true     |
      | 20  | Eva   | 2  | true     |
      | 18  | Lucie | 3  | true     |
      -------------------------------

Select with several where clauses
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

      >  SELECT * FROM metastore.students WHERE age > 19 AND enrolled = true;

      Partial result: true
      -------------------------------
      | age | name  | id | enrolled |
      -------------------------------
      | 20  | Eva   | 2  | true     |
      | 20  | Betty | 10 | true     |
      -------------------------------

Select with groupby
~~~~~~~~~~~~~~~~~~~

::

      >  SELECT age FROM metastore.students GROUP BY age;

      Partial result: true
      -------
      | age |
      -------
      | 21  |
      | 17  |
      | 18  |
      | 20  |
      | 16  |
      -------


Select with orderby
~~~~~~~~~~~~~~~~~~~

::

      >  SELECT age FROM metastore.students GROUP BY age ORDER BY age ASC;

      Partial result: true
        -------
        | age |
        -------
        | 16  |
        | 17  |
        | 18  |
        | 20  |
        | 21  |
        -------

Select Inner JOIN
~~~~~~~~~~~~~~~~~

::

    > SELECT students.id, students.age, students2.name FROM metastore.students
            INNER JOIN metastore.students2  ON students.id = students2.id;


        Partial result: true
        -----------------------
        | id | age | name     |
        +----------------------
        | 1  |  16 | Jhon     |
        | 2  |  20 | Eva      |
        | 3  |  18 | Lucie    |
        | 4  |  16 | Cole     |
        | 5  |  17 | Finn     |
        | 6  |  21 | Violet   |
        | 7  |  18 | Beatrice |
        | 8  |  20 | Henry    |
        -----------------------

Select Inner JOIN With Streaming
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can also join tables with a streaming table. We show an example using `Crossdata-Connector-Twitter <https://github.com/Stratio/crossdata/tree/master/crossdata-connector-twitter>`__.

::

    > SELECT twitterCatalog.table.id AS twitterID, testmetastore.peopleTest.id AS peopleID,
            testmetastore.people.name, twitterCatalog.twitterPeople.Lang FROM twitterCatalog.table
            WITH WINDOW 5 sec INNER JOIN testmetastore.peopleTest ON
            testmetastore.peopleTest.lang=twitterCatalog.table.Lang;


      Partial result: true
      -----------------------------------------------
      | twitterID          | peopleID | name | Lang |
      -----------------------------------------------
      | 603823152263778305 | 0        | Jhon  | es  |
      | 603823152263778305 | 1        | Eva   | es  |
      | 603823152775372803 | 0        | Jhon  | es  |
      | 603823152775372803 | 1        | Eva   | es  |
      | 603823157129150464 | 0        | Jhon  | es  |
      | 603823157129150464 | 1        | Eva   | es  |
      | 603823157162676224 | 0        | Jhon  | es  |
      | 603823157162676224 | 1        | Eva   | es  |
      | 603823159553486848 | 0        | Jhon  | es  |
      | 603823159553486848 | 1        | Eva   | es  |
      | 603823168160190464 | 0        | Eva   | es  |
      | 603823168160190464 | 1        | Lucie | es  |
      | 603823144495878145 | 0        | Eva   | es  |
      | 603823144495878145 | 1        | Lucie | es  |
      | 603823149973573632 | 0        | Cole  | es  |
      | 603823149973573632 | 1        | Lucie | es  |
      | 603823150837714944 | 0        | Jhon  | es  |
      | 603823150837714944 | 1        | Cole  | es  |
      | 603823143392825345 | 0        | Lucie | es  |
      | 603823143392825345 | 1        | Cole  | es  |
      | 603823143501828096 | 0        | Jhon  | es  |
      | 603823143501828096 | 1        | Jhon  | es  |
      -----------------------------------------------


Where to go from here
=====================

To learn more about Stratio Crossdata, we recommend you to visit the `Stratio Crossdata Reference <https://github.com/Stratio/crossdata/tree/master/doc/src/site/sphinx>`__.

