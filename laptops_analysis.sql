SELECT *
FROM laptops
ORDER BY rand() 
LIMIT 5;

## Average laptop price in our data in ~60,000
SELECT 
COUNT(Price) as num_laptops,
ROUND(MIN(Price),2) as 'minimum_price', 
ROUND(MAX(Price),2) as 'maximum_price',
ROUND(AVG(Price),2) as 'average_price',
ROUND(STD(Price),2) as 'std_dev_price'
FROM laptops;

## No Columns contain NULL Values
SELECT 
    COUNT(CASE WHEN TypeName IS NULL THEN 1 END) AS price_null_count,
    COUNT(CASE WHEN Inches IS NULL THEN 1 END) AS Inches_null_count,
    COUNT(CASE WHEN resolution_width IS NULL THEN 1 END) AS resolutionwidth_null_count,
    COUNT(CASE WHEN resolution_height IS NULL THEN 1 END) AS resolutionheight_null_count,
    COUNT(CASE WHEN touchscreen IS NULL THEN 1 END) AS touchscreen_null_count,
    COUNT(CASE WHEN cpu_brand IS NULL THEN 1 END) AS cpubrand_null_count,
    COUNT(CASE WHEN cpu_name IS NULL THEN 1 END) AS cpuname_null_count,
    COUNT(CASE WHEN cpu_speed IS NULL THEN 1 END) AS cpuspeed_null_count,
    COUNT(CASE WHEN Ram IS NULL THEN 1 END) AS Ram_null_count,
    COUNT(CASE WHEN memory_type IS NULL THEN 1 END) AS memorytype_null_count,
    COUNT(CASE WHEN primary_storage IS NULL THEN 1 END) AS primarystorage_null_count,
    COUNT(CASE WHEN secondary_storage IS NULL THEN 1 END) AS secondarystorage_null_count,
    COUNT(CASE WHEN gpu_brand IS NULL THEN 1 END) AS gpubrand_null_count,
    COUNT(CASE WHEN Weight IS NULL THEN 1 END) AS weight_null_count,
    COUNT(CASE WHEN Price IS NULL THEN 1 END) AS price_null_count
FROM laptops;

# DROPPING THESE ROWS FROM the laptops table
DELETE FROM laptops
WHERE memory_type IS NULL
OR primary_storage IS NULL 
OR Weight IS NULL;

## Creating a Histogram for Price Column
SELECT t.Price_buckets, 
REPEAT('*',COUNT(*)) as number_of_laptops
FROM (
SELECT Price,
CASE 
	WHEN Price BETWEEN 0 AND 25000 THEN '0-25K'
	WHEN Price BETWEEN 25001 AND 50000 THEN '25K-50K'
	WHEN Price BETWEEN 50001 AND 75000 THEN '50K-75K'
	WHEN Price BETWEEN 75001 AND 100000 THEN '75K-100K'
	WHEN Price BETWEEN 100001 AND 125000 THEN '100K-125K'
	WHEN Price BETWEEN 125001 AND 150000 THEN '125K-150K'
	WHEN Price BETWEEN 150001 AND 175000 THEN '150K-175K'
	WHEN Price BETWEEN 175001 AND 200000 THEN '175K-200K'
ELSE '200K+'
END AS 'Price_buckets'
FROM laptops
) AS t
GROUP BY t.Price_buckets;

## Counting laptops by Company
SELECT Company, COUNT(*)
FROM laptops
GROUP BY Company
ORDER BY 2 DESC;

## windows has the largest share in our dataset
SELECT OpSys, COUNT(*)
FROM laptops
GROUP BY OpSys
ORDER BY 2 DESC;

## Summary table for each Company
SELECT Company, COUNT(touchscreen) as touchscreen, 
AVG(Ram) as average_ram, AVG(cpu_speed) as average_cpuspeed, ROUND(AVG(Weight),2) as average_weight,
ROUND(AVG(Price)) as 'avg_price'
FROM laptops
GROUP BY Company;

## Breakdown of Touchscreen Laptops
SELECT Company,
SUM(CASE WHEN Touchscreen=1 THEN 1 ELSE 0 END) AS 'touchscreen_yes',
SUM(CASE WHEN Touchscreen=0 THEN 1 ELSE 0 END) AS 'touchscreen_no'
FROM laptops
GROUP BY Company;

## Lenovo has the most laptops with a Nvidia GPU
SELECT Company,
SUM(CASE WHEN gpu_brand LIKE '%Nvidia%' THEN 1 ELSE 0 END) AS 'nvidia_gpu',
SUM(CASE WHEN gpu_brand NOT LIKE '%Nvidia%' THEN 1 ELSE 0 END) AS 'other_gpu'
FROM laptops
GROUP BY Company
ORDER BY nvidia_gpu DESC;

## CPU Brand by Company
SELECT Company,
SUM(CASE WHEN cpu_brand='Intel' THEN 1 ELSE 0 END) AS 'Intel',
SUM(CASE WHEN cpu_brand='AMD' THEN 1 ELSE 0 END) AS 'AMD',
SUM(CASE WHEN cpu_brand='Samsung' THEN 1 ELSE 0 END) AS 'Samsung'
FROM laptops
GROUP BY Company
ORDER BY Company;

## Analyzing laptop prices by Company. The most number of laptops are by Lenovo
SELECT Company, ROUND(MIN(Price),2) as 'min_price', 
ROUND(MAX(Price),2) as 'max_price', ROUND(AVG(Price),2) as 'avg_price',
ROUND(STD(Price),2) as 'std_price', COUNT(*) as 'number_of_laptops'
FROM laptops
GROUP BY Company
ORDER BY number_of_laptops DESC;

## If we dont drop NULL values then the code below can help us set NULL values in Price to Average Price
# UPDATE laptops
# SET Price = AVG(Price)
# WHERE Price IS NULL

## Alteratively we can also set the price to be average of the corresponding company using the code below
# UPDATE laptops as l1
# SET Price=(
# 			SELECT AVG(Price) 
#             FROM laptops as l2 
#             WHERE l2.Company=l1.Company
#             )
# WHERE Price IS NULL


## Feature Engineering. Adding a new PPI Column
ALTER TABLE laptops
ADD COLUMN ppi INTEGER;

UPDATE laptops
SET ppi= ROUND(SQRT(resolution_width*resolution_width + resolution_height*resolution_height)/Inches);

## Adding a new screen size 
ALTER TABLE laptops
ADD COLUMN screen_size VARCHAR(100) AFTER inches;

# We are dividing laptops into small, medium and large screen sizes
UPDATE laptops
SET screen_size = 
CASE 
	WHEN inches < 14 THEN 'small'
    WHEN inches > 14 AND inches < 17 THEN 'medium'
    ELSE 'large'
END;

## We can see that large size laptops are the most expensive in average price
SELECT screen_size,AVG(price) 
FROM laptops
GROUP BY screen_size;