select transactionid
          ,count(*) 
          from Sales_transaction
          group by transactionid
          having count(*) > 1;

CREATE TABLE Unique_Sales_transaction AS
SELECT DISTINCT *
FROM Sales_transaction;

drop table Sales_transaction;

ALTER TABLE Unique_Sales_transaction RENAME TO Sales_transaction;

select * from Sales_transaction;


WITH ProductProfits AS (
    SELECT 
        pi.productID,
        pi.productName,
        SUM(st.quantitypurchased * pi.price) AS total_profit
    FROM 
        sales_transaction st
    JOIN 
        product_inventory pi ON st.productid = pi.productid
    GROUP BY 
        pi.productid, pi.productname
),
TotalProfit AS (
    SELECT SUM(total_profit) AS overall_profit
    FROM ProductProfits
),
ProductRanked AS (
    SELECT 
        productid,
        productname,
        total_profit,
        SUM(total_profit) OVER (ORDER BY total_profit DESC) AS cumulative_profit,
        (SELECT overall_profit FROM TotalProfit) AS overall_profit
    FROM ProductProfits
)
SELECT 
    productid,
    productname,
    total_profit,
    cumulative_profit,
    overall_profit,
    cumulative_profit / overall_profit * 100 AS cumulative_profit_percentage
FROM 
    ProductRanked
WHERE 
    cumulative_profit / overall_profit <= 0.80
ORDER BY 
    total_profit DESC,productid;
    -- LIMIT (SELECT COUNT(*) * 0.2 FROM ProductProfits);
    

select count(*) from customer_profiles
where location is null;

select customerid,age,gender,if(location is null,'unknown',location) Location,joindate
from customer_profiles;

-- select * from Sales_transaction;

create table new_table as 
select * from Sales_transaction;

alter table new_table
modify transactionDate date;

alter table new_table
add transactionDate_updated date;

update new_table
set transactionDate_updated = transactionDate
where transactionDate_updated is null;

alter table new_table
modify transactionDate_updated date;

drop table Sales_transaction;

alter table new_table rename to  Sales_transaction;

select * from Sales_transaction;

-- select * from Sales_transaction;

select productid,sum(quantitypurchased) as TotalUnitsSold
,Sum(price*quantitypurchased) as Totalsales from Sales_transaction
group by productid
order by totalsales desc;

-- select * from Sales_transaction;

select customerid
,count(transactionid) as NumberofTransactions from Sales_transaction
group by customerid
order  by NumberofTransactions desc;

-- select * from product_inventory;

select category
              ,sum(quantitypurchased) as TotalUnitsSold
              ,sum(quantitypurchased*s.price) as TotalSales
              from Sales_transaction s
              inner join product_inventory p
              on s.productid=p.productid
              group by category
              order by TotalSales desc;

-- select * from Sales_transaction;

select productid
          ,sum(quantitypurchased*price) as TotalRevenue
          from Sales_transaction
          group by productid
          order by TotalRevenue desc
          limit 10;
          
select productid
          ,sum(quantitypurchased) as TotalunitsSold
          from Sales_transaction
          group by productid
          having TotalunitsSold>=1
          order by TotalunitsSold asc
          limit 10;

-- select * from sales_transaction;

select cast(TransactionDate_updated as date) as DATETRANS
          ,count(*) as Transaction_count
          ,sum(quantitypurchased) as TotalUnitsSold
          ,sum(quantitypurchased*price) as TotalSales
          from sales_transaction
          group by DATETRANS
          order by DATETRANS desc;

-- select last_value(TransactionDate_updated) over (order by TransactionDate_updated desc) from sales_transaction;

with MonthlySales  as ( 
    select DATE_FORMAT(TransactionDate_updated,'%m') as months
    ,sum(quantitypurchased*price) as total_sales
    from sales_transaction
    group by months
),
SalesGrowth  as(
    select round(months,1) as month
    ,total_sales
    ,lag(Total_sales) over (order by months) as previous_month_sales
    from MonthlySales
)

select month
          ,total_sales
          ,previous_month_sales
          ,(Total_sales-previous_month_sales)/previous_month_sales*100 as mom_growth_percentage
          from SalesGrowth;

-- select * from sales_transaction;

select customerid
          ,count(transactionid) as NumberofTransactions
          ,SUM(quantitypurchased*price) as TotalSpent
          from sales_transaction
          group by customerid
          having NumberofTransactions > 10 and TotalSpent > 1000
          order by TotalSpent desc;

select customerid
          ,count(transactionid) as NumberofTransactions
          ,SUM(quantitypurchased*price) as TotalSpent
          from sales_transaction
          group by customerid
          having NumberofTransactions <= 2
          order by NumberofTransactions asc,TotalSpent desc;

-- select * from Sales_transaction;

select customerid
          ,productid
          ,count(transactionid) as Timespurchased
          from Sales_transaction
          group by customerid,productid
          having Timespurchased>1
          order by Timespurchased desc;

SELECT CUSTOMERID
            , MIN(DATE_UPDT) FIRSTPURCHASE
            , MAX(DATE_UPDT) LASTPURCHASE
            , DATEDIFF(MAX(DATE_UPDT),MIN(DATE_UPDT)) AS DAYSBETWEENPURCHASES
            FROM (
SELECT CUSTOMERID
            , STR_TO_DATE(TRANSACTIONDATE, '%Y-%m-%d') AS DATE_UPDT
            FROM SALES_TRANSACTION
            ) A
            GROUP BY 
            CUSTOMERID
            HAVING DATEDIFF(MAX(DATE_UPDT),MIN(DATE_UPDT)) > 0
            ORDER BY 
            DAYSBETWEENPURCHASES DESC;
            
create table customer_segment as
with new_table as(
    select distinct CustomerID
    ,sum(quantitypurchased) as Totalquantity
    from sales_transaction
    group by CustomerID
)
select case 
            when Totalquantity between 1 and 9 then 'Low'
            when Totalquantity between 10 and 30  then 'Med'
            else 'High'
            end as CustomerSegment,
            count(*)
            From new_table
            group by customersegment;

select * from customer_segment;

-- select * from sales_transaction;

CREATE TABLE CUSTOMER_SEG AS 

SELECT CUSTOMERID

            , CASE WHEN TOTALQUANTITY > 30 THEN "HIGH"

                        WHEN TOTALQUANTITY BETWEEN 10 AND 30 THEN "MED"

                        WHEN TOTALQUANTITY BETWEEN 1 AND 10 THEN "LOW"

                        ELSE "NONE" END CUSTOMERSEGMENT

            FROM (

                SELECT C.CUSTOMERID

                            , SUM(S.QUANTITYPURCHASED) AS TOTALQUANTITY

                            FROM CUSTOMER_PROFILES C

                            JOIN SALES_TRANSACTION S 

                            ON C.CUSTOMERID = S.CUSTOMERID

                            GROUP BY C.CUSTOMERID 

            )  AS TQ;

SELECT CUSTOMERSEGMENT

            , COUNT(*) 

            FROM CUSTOMER_SEG

            GROUP BY CUSTOMERSEGMENT;

            

