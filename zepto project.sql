drop table if exists zepto;

CREATE TABLE zepto (
  sku_id SERIAL PRIMARY KEY,
  category VARCHAR(120),
  name VARCHAR(150) NOT NULL,
  mrp NUMERIC(8,2),
  discountPercent NUMERIC(5,2),
  availableQuantity INTEGER,
  discountedSellingPrice NUMERIC(8,2),
  weightInGms INTEGER,
  outOfStock BOOLEAN,
  quantity INTEGER
);

-- data exploration
-- count of rows
Select count(*) from zepto;
--SELECT current_database();
--sample data
select * from zepto limit 10;
-- null values
select * from zepto where 
name is null or
category is null or
mrp is null or
discountpercent is null or
availablequantity is null or
discountedsellingprice is null or
weightingms is null or
outofstock is null or
quantity is null;

-- different product categories
Select distinct category
from zepto
order by category desc;

--products in stock vs out of stock
select outofstock,count(sku_id)
from zepto
group by outofstock;

--product name presenrt in mutiple times
select name,count(sku_id) as "Number of Skus"
from zepto
group by name
having count(sku_id)>1
order by count(sku_id) desc;

--data cleaning
-- product with price 0
Select * from zepto 
where mrp=0 or discountedsellingprice=0;

Delete from zepto
where mrp=0;

--convert paise to rupees
update zepto
set mrp=mrp/100.0,
discountedsellingprice=discountedsellingprice/100.0;

Select mrp, discountedsellingprice from zepto;

--Found top 10 best-value products based on discount percentage
Select distinct name,mrp,discountpercent
from zepto
order by discountpercent desc
limit 10;

--identified high-MRP products that are currently out of stock
select  name,max(mrp) as "Highest Mrp" 
from zepto where outOfStock=True 
group by name
order by max(mrp) desc 
limit 1;
-- or 
select distinct name,mrp
from zepto where outofStock=True
and mrp>300
order by mrp desc limit 1;
--Estimated potential revenue for each product category
select category,
sum(discountedsellingprice * availablequantity) as total_revenue
from zepto
group by category
order by total_revenue;

--Filtered expensive products (MRP > ₹500) with discount is less than 10%
select distinct name,mrp,discountpercent
from zepto
where mrp>500 and discountpercent<10
order by mrp desc ,discountpercent desc;

--Ranked top 5 categories offering highest average discounts
select category,round(avg(discountpercent),1) as average_discount
from zepto 
group by category
order by average_discount desc limit 5;
--Calculated price per gram to identify value-for-money products
select distinct name,weightingms,discountedsellingprice,
round(discountedsellingprice/weightingms,2) as price_per_grams
from zepto
where weightingms>=100
order by price_per_grams;

--Grouped products based on weight into Low, Medium, and Bulk categories
Select  distinct name, weightingms,
case when  weightingms<100 then 'low'
when  weightingms<500 then 'medium'
else 'Bulk'
end as weight_cat
from zepto;
--Measured total inventory weight per product category
select category,
sum(weightingms*availablequantity) as total_weight
from zepto
group by category
order by total_weight
