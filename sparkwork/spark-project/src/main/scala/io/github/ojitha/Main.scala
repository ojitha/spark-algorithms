import org.apache.spark.sql.SparkSession

import org.apache.spark.sql._
import org.apache.log4j.{Level, Logger}

// Silence logs


object Main {
  def main(args: Array[String]): Unit = {
    
    Logger.getLogger("org").setLevel(Level.ERROR)
    Logger.getLogger("com").setLevel(Level.ERROR)

val spark = SparkSession.builder()
  .appName("YourApp")
  .master("local[*]")
  .getOrCreate()

    spark.sparkContext.setLogLevel("ERROR")
    import spark.implicits._
    println("Spark Version : " + spark.version)
    
    // Example: Create a simple DataFrame
    val data = Seq(1, 2, 3, 4, 5, 6, 7)
    val df = spark.createDataFrame(data.map(Tuple1(_))).toDF("value")
    df.show()

    spark.stop()
  }
}