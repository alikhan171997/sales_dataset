-- Data Cleaning

select count(ORDERNUMBER) from sales_data_sample;

-- create copy of data to work on 

create table if not exists sds_copy 
like sales_data_sample ;

insert into sds_copy
select * from sales_data_sample;

-- Removing Duplicates

with sds_copy10 as (
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, 
                        ORDERDATE, `STATUS`, QTR_ID, MONTH_ID, YEAR_ID, PRODUCTLINE, 
                        MSRP, PRODUCTCODE, CUSTOMERNAME, PHONE, ADDRESSLINE1, ADDRESSLINE2, 
                        CITY, STATE, POSTALCODE, COUNTRY, TERRITORY, CONTACTLASTNAME, 
                        CONTACTFIRSTNAME, DEALSIZE
       ) AS row_num
FROM sds_copy)
select * from sds_copy10 
where row_num > 2 ;

-- transfering all the row except duplicates into new table

CREATE TABLE `sds_copy2` (
  `ORDERNUMBER` int DEFAULT NULL,
  `QUANTITYORDERED` int DEFAULT NULL,
  `PRICEEACH` double DEFAULT NULL,
  `ORDERLINENUMBER` int DEFAULT NULL,
  `SALES` double DEFAULT NULL,
  `ORDERDATE` text,
  `STATUS` text,
  `QTR_ID` int DEFAULT NULL,
  `MONTH_ID` int DEFAULT NULL,
  `YEAR_ID` int DEFAULT NULL,
  `PRODUCTLINE` text,
  `MSRP` int DEFAULT NULL,
  `PRODUCTCODE` text,
  `CUSTOMERNAME` text,
  `PHONE` text,
  `ADDRESSLINE1` text,
  `ADDRESSLINE2` text,
  `CITY` text,
  `STATE` text,
  `POSTALCODE` text,
  `COUNTRY` text,
  `TERRITORY` text,
  `CONTACTLASTNAME` text,
  `CONTACTFIRSTNAME` text,
  `DEALSIZE` text,
  row_num int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO sds_copy2 (
    ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, ORDERDATE, 
    STATUS, QTR_ID, MONTH_ID, YEAR_ID, PRODUCTLINE, MSRP, PRODUCTCODE, CUSTOMERNAME, 
    PHONE, ADDRESSLINE1, ADDRESSLINE2, CITY, STATE, POSTALCODE, COUNTRY, TERRITORY, 
    CONTACTLASTNAME, CONTACTFIRSTNAME, DEALSIZE, row_num
)
SELECT ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, ORDERDATE, 
       STATUS, QTR_ID, MONTH_ID, YEAR_ID, PRODUCTLINE, MSRP, PRODUCTCODE, CUSTOMERNAME, 
       PHONE, ADDRESSLINE1, ADDRESSLINE2, CITY, STATE, POSTALCODE, COUNTRY, TERRITORY, 
       CONTACTLASTNAME, CONTACTFIRSTNAME, DEALSIZE,
       ROW_NUMBER() OVER (
           PARTITION BY ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, 
                        ORDERDATE, STATUS, QTR_ID, MONTH_ID, YEAR_ID, PRODUCTLINE, 
                        MSRP, PRODUCTCODE, CUSTOMERNAME, PHONE, ADDRESSLINE1, ADDRESSLINE2, 
                        CITY, STATE, POSTALCODE, COUNTRY, TERRITORY, CONTACTLASTNAME, 
                        CONTACTFIRSTNAME, DEALSIZE
       ) AS row_num
FROM sds_copy
where row_num = 1;

select COUNTRY, PHONE, length(PHONE) as len_phone from sds_copy2
order by COUNTRY Desc;


select COUNTRY, avg(length(PHONE)) as len_phone from sds_copy2
group by COUNTRY order by COUNTRY Desc;

alter table sds_copy2
drop column ADDRESSLINE2, 
drop column STATE;

select * from sds_copy2;

-- fixing the date column standardizing the dataset

alter table sds_copy2
add column new_date date;

SET SQL_SAFE_UPDATES = 1;

UPDATE sds_copy2
SET new_date = STR_TO_DATE(ORDERDATE, '%m/%d/%Y %H:%i')
WHERE ORDERDATE IS NOT NULL;

ALTER TABLE sds_copy2
DROP COLUMN ORDERDATE;

ALTER TABLE sds_copy2
CHANGE COLUMN new_date ORDERDATE DATE;