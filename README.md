# spark-algorithms

To create almond locall kernal
```bash
cs launch almond:0.14.1 --scala 2.12.20 --   --install   --id scala-spark-3.3.1   --display-name "Scala 2.12.20 (Spark 3.2.1)"   --predef-code  "import \$cp.\`$SPARK_HOME/jars/*\`"
```

To list kernels:
```bash
uv run jupyter kernelspec list
```