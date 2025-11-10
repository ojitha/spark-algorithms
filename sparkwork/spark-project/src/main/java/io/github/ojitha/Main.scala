import org.apache.spark.sql.SparkSession

object Main {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder()
      .appName("SparkProject")
      .master("local[*]")
      .getOrCreate()

    println("Spark Version: " + spark.version)
    
    // Example: Create a simple DataFrame
    val data = Seq(1, 2, 3, 4, 5)
    val df = spark.createDataFrame(data.map(Tuple1(_))).toDF("value")
    df.show()

    spark.stop()
  }
}