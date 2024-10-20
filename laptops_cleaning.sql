SELECT *
FROM laptops;

# creating a backup table
CREATE TABLE IF NOT EXISTS laptop_backup LIKE laptops;

# insert data into backup table if needed using the code below
# INSERT INTO laptop_backup
# SELECT * FROM laptops;

# We have 1272 rows in the data
SELECT COUNT(*)
FROM laptops;

# Memory Occupied by Table
SELECT *
FROM information_schema.TABLES
WHERE TABLE_SCHEMA='case_study' AND TABLE_NAME='laptops';

# Data Cleaning. Dropping Columns
ALTER TABLE laptops
DROP COLUMN `Unnamed: 0`;

# Since COUNT = 1 we dont have duplicate rows
SELECT Company, TypeName, Inches, ScreenResolution, Cpu, Ram, Memory,Gpu, OpSys, Weight, Price, COUNT(*)
FROM laptops
GROUP BY Company, TypeName, Inches, ScreenResolution, Cpu, Ram, Memory,Gpu, OpSys, Weight, Price;

## changing INches column from string to decimal data type
ALTER TABLE laptops
MODIFY COLUMN Inches DECIMAL(10,1);

## Removing GB from ram and converting it into a integer column
UPDATE laptops
SET Ram = REPLACE(Ram,'GB','');

ALTER TABLE laptops
MODIFY COLUMN Ram INTEGER;

# Memory Occupied by Table is now 256
SELECT DATA_LENGTH/1024 
FROM information_schema.TABLES
WHERE TABLE_SCHEMA='case_study'
AND TABLE_NAME='laptops';

# Removing the string kg from Weight
UPDATE laptops
SET Weight = REPLACE(Weight,'kg','');

UPDATE laptops 
SET Weight = NULL 
WHERE Weight = '?';

# Changing weight to a decimal data type
UPDATE laptops
SET Weight=CAST(Weight AS DECIMAL(10,3));

UPDATE laptops
SET Price= ROUND(Price,0);

# Changing Price to an integer data type
ALTER TABLE laptops
MODIFY COLUMN Price INTEGER;

# We are dividing OpSys column into macos,windows,linux,No Os and other categories
UPDATE laptops
SET OpSys = CASE
	WHEN OpSys LIKE '%mac%' THEN 'macos'
    WHEN OpSys LIKE 'windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys = 'No OS' THEN 'N/A'
    ELSE 'other' 
END;

ALTER TABLE laptops
ADD COLUMN gpu_brand VARCHAR(255) AFTER Gpu;

ALTER TABLE laptops
ADD COLUMN gpu_name VARCHAR(255) AFTER gpu_brand;

UPDATE laptops
SET gpu_brand = substring_index(Gpu,' ',1);

UPDATE laptops
SET gpu_name=REPLACE(Gpu,gpu_brand,'');

ALTER TABLE laptops
DROP COLUMN Gpu;

ALTER TABLE laptops
ADD COLUMN cpu_brand VARCHAR(255) AFTER Cpu;

ALTER TABLE laptops
ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand;

ALTER TABLE laptops
ADD COLUMN cpu_speed DECIMAL(10,1) AFTER cpu_name;

UPDATE laptops
SET cpu_brand = SUBSTRING_INDEX(Cpu, ' ',1);

UPDATE laptops
SET cpu_speed = CAST(REPLACE(SUBSTRING_INDEX(Cpu,' ',-1),'GHz','') AS DECIMAL(10,1));

SELECT REPLACE(Cpu,Cpu_brand,'')
FROM laptops;

SELECT REPLACE(Cpu,CONCAT(cpu_speed,'GHz'),'')
FROM laptops;

UPDATE laptops
SET cpu_name = REPLACE(REPLACE(Cpu,cpu_brand,''),SUBSTRING_INDEX(REPLACE(Cpu,cpu_brand,''),' ',-1),'');

## Removing the original CPU Column
ALTER TABLE laptops
DROP COLUMN Cpu;

SELECT *
FROM laptops;

## Adding a new column: resolution width
ALTER TABLE laptops
ADD COLUMN resolution_width INT AFTER ScreenResolution;

# Adding a new column: resolution height
ALTER TABLE laptops
ADD COLUMN resolution_height INT AFTER resolution_width;


SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution," ",-1),'x',1),
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution," ",-1),'x',-1)
FROM laptops;

UPDATE laptops
SET resolution_height = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution," ",-1),'x',-1),
	resolution_width=SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution," ",-1),'x',1);

# We will find laptops if they are touchscreen    
ALTER TABLE laptops
ADD COLUMN touchscreen INTEGER AFTER resolution_height;


UPDATE laptops
SET touchscreen=ScreenResolution LIKE '%Touch%';

ALTER TABLE laptops
DROP COLUMN ScreenResolution;

UPDATE laptops
SET cpu_name=SUBSTRING_INDEX(TRIM(cpu_name),' ',2);

SELECT Memory 
FROM laptops;

ALTER TABLE laptops
ADD COLUMN memory_type VARCHAR(255) AFTER Memory,
ADD COLUMN primary_storage INTEGER AFTER memory_type,
ADD COLUMN secondary_storage INTEGER AFTER primary_storage;

UPDATE laptops
SET memory_type = CASE
	WHEN Memory LIKE '%SSD%' and Memory LIKE '%HDD%' THEN 'Hybrid'
    WHEN Memory LIKE '%SSD%' THEN 'SSD'
    WHEN Memory LIKE '%HDD%' THEN 'HDD'
    WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
    WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    ELSE NULL
END;

## Here we only want the second column to be populated if there is a + in the memory column else we say 0
# We use REGEXP below to extract the number from the memory column. 
# SQL will perform implicit type conversion and population both primary and secondary columns

UPDATE laptops
SET primary_storage=REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
secondary_storage=CASE WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END;


## If we see 1 or 2 in primary and secondary since that is TB and not GB. We multiply it by 1024 to get GB values
UPDATE laptops
SET primary_storage= CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
	secondary_storage= CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE secondary_storage END;

# Removing the memory column and gpu_name column below
ALTER TABLE laptops 
DROP COLUMN Memory;

ALTER TABLE laptops
DROP COLUMN gpu_name;