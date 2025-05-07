desc Customers;
desc Products;
desc Orders;
desc OrderDetails;

-- select * from Customers;

select location,count(name) as number_of_customers from Customers
group by location
order by number_of_customers desc
limit 3;

with new_table as(
          select customer_id
          ,count(order_id) as NumberOfOrders
          from Orders
          group by customer_id
)
select NumberOfOrders,
          case
          when numberoforders = 1 then count(numberoforders)
          when numberoforders between 2 and 4 then count(numberoforders)
          else count(numberoforders)
          end as CustomerCount
          from new_table
          group by NumberOfOrders
          order by NumberOfOrders;
	
select product_id
          ,avg(quantity) as AvgQuantity
          ,Sum(quantity*price_per_unit) as TotalRevenue
          from OrderDetails
          group by product_id
          HAVING AvgQuantity = 2
          order by TotalRevenue desc;
          

select category,count(distinct customer_id) as unique_customers from  products p
inner join OrderDetails OD
on p.product_id=OD.product_id
inner join Orders o
on OD.order_id=o.order_id
group by category
order by unique_customers desc;

with new_table as (
    select date_format(order_date,'%Y-%m') as Month
    ,sum(total_amount) as TotalSales
    ,lag(sum(total_amount)) over (order by date_format(order_date,'%Y-%m')) as LagTotalSales
    from orders
    group by month
    )
        select Month
        ,TotalSales
        ,round((TotalSales-LagTotalSales)/LagTotalSales * 100,2) as PercentChange
        from new_table;
        
with new_table as (
    select date_format(order_date,'%Y-%m') as Month
    ,avg(total_amount) as AvgOrderValue
    ,lag(avg(total_amount)) over (order by date_format(order_date,'%Y-%m')) as LagAvgOrderValue
    from orders
    group by month
    )
        select Month
        ,AvgOrderValue
        ,round(AvgOrderValue-LagAvgOrderValue,2) as ChangeInValue
        from new_table
        order by ChangeInValue desc;

select product_id,count(order_id) as SalesFrequency from OrderDetails
group by product_id
order by SalesFrequency desc
limit 5;

WITH ProductCustomerCount AS (
    SELECT 
        p.product_id AS Product_id, 
        p.name AS Name, 
        COUNT(DISTINCT c.customer_id) AS UniqueCustomerCount
    FROM 
        products p
    INNER JOIN 
        orderdetails od ON p.product_id = od.product_id
    INNER JOIN 
        orders o ON o.order_id = od.order_id
    INNER JOIN 
        customers c ON c.customer_id = o.customer_id
    GROUP BY 
        p.product_id, p.name
)

SELECT 
    Product_id, 
    Name, 
    UniqueCustomerCount
FROM 
    ProductCustomerCount
WHERE 
    UniqueCustomerCount < (SELECT COUNT(*) FROM customers) * 0.40;
    
with new_table as (
    select count(distinct customer_id) as new_count
    ,date_format(min(order_date),'%Y-%m') as FirstPurchaseMonth 
    from orders
    group by customer_id
    )
select FirstPurchaseMonth,count(new_count) as TotalNewCustomers from new_table 
group by FirstPurchaseMonth
order by FirstPurchaseMonth asc;

select date_format(order_date,'%Y-%m') as month
           ,sum(total_amount) as TotalSales
           from orders
           group by month
           order by TotalSales desc
           limit 3;
        
