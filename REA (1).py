from pyspark.sql import SparkSession
from pyspark.sql.functions import col, when, avg, count

# STEP 1: Create Spark Session
spark = SparkSession.builder.appName("SupplyChain_REA").getOrCreate()

# STEP 2: Load dataset
df = spark.read.csv("SupplychainData.csv", header=True, inferSchema=True)

# STEP 3: Rename columns
df = df.withColumnRenamed("Days for shipping (real)", "ATA") \
       .withColumnRenamed("Days for shipment (scheduled)", "ETA")

# STEP 4: Create Delay column
df = df.withColumn("Delay", col("ATA") - col("ETA"))

# STEP 5: Create Delay Status
df = df.withColumn("Delay_Status",
                   when(col("Delay") > 0, "Late").otherwise("On Time"))

# STEP 6: Create Route
df = df.withColumn("Route", col("Order Region"))

# STEP 7: Show shipment-level data
print("\n📦 Shipment-Level Data:")
df.select("Order Id", "Route", "ATA", "ETA", "Delay", "Delay_Status").show(10)

# STEP 8: Route Efficiency Analysis
route_analysis = df.groupBy("Route").agg(
    avg("Delay").alias("Average_Delay"),
    count("Order Id").alias("Total_Orders")
).orderBy(col("Average_Delay").desc())

print("\n📊 Route Efficiency Analysis:")
route_analysis.show()

# STEP 9: On-Time Delivery %
total = df.count()
on_time = df.filter(col("Delay") <= 0).count()
on_time_percentage = (on_time / total) * 100

print(f"\n✅ On-Time Delivery %: {on_time_percentage:.2f}%")

# STEP 10: Save final dataset for Power BI
df.toPandas().to_csv("Final_REA_Data.csv", index=False)

print("\n💾 Final dataset saved successfully!")