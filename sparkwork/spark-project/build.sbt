
name := "spark-project"

version := "1.0"

scalaVersion := "2.13.12"

libraryDependencies ++= Seq(
  "org.apache.spark" %% "spark-core" % "3.5.7",
  "org.apache.spark" %% "spark-sql" % "3.5.7",
  // "org.apache.spark" %% "spark-mllib" % "3.1.3",
)