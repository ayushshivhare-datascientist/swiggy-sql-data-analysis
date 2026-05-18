select * from swiggy_data

-- Data validation & Cleaning
-- Null Check

SELECT
    SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS null_restaurant_name,
    SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_location,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS null_dish,
    SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
    SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) AS null_rating_Count
FROM swiggy_data;

-- Blank or Empty Strings
select * from swiggy_data
where state = '' or City = '' or Restaurant_Name = '' or Location = '' or Category = '' or Dish_Name = ''

-- Duplicate Detection
SELECT 
    State, City, Order_Date, Restaurant_Name, Location, Category, 
    Dish_Name, Price_INR, Rating, Rating_Count,
    COUNT(*) AS duplicate_count
FROM swiggy_data
GROUP BY 
    State, City, Order_Date, Restaurant_Name, Location, Category, 
    Dish_Name, Price_INR, Rating, Rating_Count
HAVING COUNT(*) > 1;

-- Delete Duplication
with CTE as (
select *, ROW_NUMBER() Over(
    PARTITION BY State, order_date, restaurant_name, location, category, dish_name, price_INR, rating, rating_count
order by (select NULL)
) as rn
from swiggy_data
)
DELETE FROM CTE where rn>1

-- Creating Schema
-- Dimension Table
-- Date Table
Create Table dim_date (
    Date_Id INT IDENTITY(1,1) PRIMARY KEY,
    Full_Date DATE,
    Year INT,
    Month INT,
    Month_Name varchar(20),
    Quarter INT,
    Day INT,
    Week INT)

-- dim_location
CREATE TABLE dim_location (
    location_id INT IDENTITY(1,1) PRIMARY KEY,
    State VARCHAR(100),
    City VARCHAR(100),
    Location VARCHAR(200))

-- dim_restaurant
CREATE TABLE dim_restaurant (
    restaurant_id INT IDENTITY(1,1) PRIMARY KEY,
    Restaurant_Name VARCHAR (200))

-- dim_category
CREATE TABLE dim_category (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    Category VARCHAR(200))

-- dim_dish
CREATE TABLE dim_dish (
    dish_id INT IDENTITY(1,1) PRIMARY KEY,
    Dish_Name VARCHAR(200))

-- Fact Table
CREATE TABLE fact_swiggy_orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,

    date_id INT,
    Price_INR DECIMAL(10,2),
    Rating DECIMAL (4,2),
    Rating_Count INT,

    location_id INT,
    restaurant_id INT,
    category_id INT,
    dish_id INT,

    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
    FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
    FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
    FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id))

-- INSERT DATA IN TABLES
-- dim_date
INSERT INTO dim_date (Full_Date, Year, Month, Month_Name, Quarter, Day, Week)
SELECT DISTINCT
    Order_Date,
    YEAR(Order_Date),
    MONTH(Order_Date),
    DATENAME(MONTH, Order_Date),
    DATEPART(QUARTER, Order_Date),
    DAY(Order_Date),
    DATEPART(WEEK, Order_Date)
FROM swiggy_data
where Order_Date IS NOT NULL

select * from dim_date

-- dim_location
INSERT INTO dim_location (State, City, Location)
select distinct State, City, Location from swiggy_data

select * from dim_location

-- dim_category
INSERT INTO dim_category (Category)
select distinct Category From swiggy_data

select * from dim_category

-- dim_restaurant
INSERT INTO dim_restaurant(Restaurant_Name)
select distinct Restaurant_Name From swiggy_data

select * from dim_restaurant

-- dim_dish
INSERT INTO dim_dish(Dish_Name)
select distinct Dish_Name From swiggy_data

select * from dim_dish

-- Fact_Table
INSERT INTO fact_swiggy_orders
        (date_id,Price_INR,
        Rating,Rating_Count,location_id,
        restaurant_id,category_id,dish_id)

select dd.date_id,s.Price_INR,s.Rating,s.Rating_Count,
        dl.location_id,dr.restaurant_id,dc.category_id,dsh.dish_id 
from swiggy_data s
join dim_date dd ON dd.Full_Date = s.Order_Date

join dim_location dl ON dl.State = s.State AND dl.City = s.City AND dl.Location = s.Location

join dim_restaurant dr on dr.Restaurant_Name = s.Restaurant_Name

join dim_category dc on dc.Category = s.Category

join dim_dish dsh on dsh.Dish_Name = s.Dish_Name



select * from fact_swiggy_orders f
join dim_date d on f.date_id = d.date_id
join dim_location l on f.location_id = l.location_id
join dim_restaurant r on f.restaurant_id = r.restaurant_id
join dim_category c on f.category_id = c.category_id
join dim_dish di on f.dish_id = di.dish_id

-- Kpi's
-- Total Orders
select COUNT(*) as Total_Orders from fact_swiggy_orders

-- Total Revenue (INR Million)
select Format(SUM(Convert(Float,Price_INR))/1000000, 'N2') +' INR Million'
as Total_Revenue from fact_swiggy_orders

-- Average Dish Price
select Format(AVG(Convert(Float,Price_INR)), 'N2') +' INR'
as AVG_Dish_Price from fact_swiggy_orders

-- Average Rating
select AVG(Rating) as Avg_Rating from fact_swiggy_orders

-- Deep-Dive Business Analysis

-- Monthly Order Trends
select d.year, d.Month,d.Month_Name, count(*) as Total_Orders from fact_swiggy_orders f
join dim_date d on f.date_id =d.date_id
group by d.year, d.Month,d.Month_Name

-- Quaterly Trend
select d.year, d.Quarter, count(*) as Total_Orders from fact_swiggy_orders f
join dim_date d on f.date_id =d.date_id
group by d.year, d.Quarter

-- Yearly Trend
select d.year, count(*) as Total_Orders from fact_swiggy_orders f
join dim_date d on f.date_id =d.date_id
group by d.year

-- Orders By Day of Week (Mon-Sun)
select DATENAME(WEEKDAY, d.full_date) as day_name,
        COUNT(*) as Total_Orders
From fact_swiggy_orders f
join dim_date d on f.date_id = d.Date_Id
Group by DATENAME(WEEKDAY, d.full_date), DATEPART(WEEKDAY, d.full_date)
order by DATEPART(WEEKDAY, d.full_date)

-- Top 10 cities by order valume
select Top 10 l.city, COUNT(*) as Total_Orders from fact_swiggy_orders f
join dim_location l on l.location_id = f.location_id
group by l.City
Order by Total_Orders desc

-- Revenue Contribution by States
select l.State, SUM(Price_INR) as Total_Revenue from fact_swiggy_orders f
join dim_location l on l.location_id = f.location_id
group by l.State
Order by Total_Revenue desc

-- Top 10 Restaurants By Orders
select Top 10 r.Restaurant_Name, COUNT(*) as Total_Orders from fact_swiggy_orders f
join dim_restaurant r on r.restaurant_id = f.restaurant_id
group by r.Restaurant_Name
Order by Total_Orders desc

-- Top Categories
select  c.Category, COUNT(*) as Total_Orders from fact_swiggy_orders f
join dim_category c on c.category_id = f.category_id
group by c.Category
Order by Total_Orders desc

-- Most Order Dishes
select  d.Dish_Name, COUNT(*) as Total_Orders from fact_swiggy_orders f
join dim_dish d on d.dish_id = f.dish_id
group by d.Dish_Name
Order by Total_Orders desc

-- Cuisine Performance (Orders+AVG Rating)
select  c.Category, COUNT(*) as Total_Orders,AVG(f.rating) as Avg_Rating  from fact_swiggy_orders f
join dim_category c on c.category_id = f.category_id
group by c.Category
Order by Total_Orders desc

--Total Orders by Price Range
select
    case
        when price_inr < 100 THEN 'Under 100'
        when price_inr BETWEEN 100 AND 199 THEN '100 - 199'
        when price_inr BETWEEN 200 AND 299 THEN '200 - 299'
        when price_inr BETWEEN 300 AND 499 THEN '300 - 499'
            ELSE '500+'
        END AS price_range,COUNT(*) AS total_orders
    From fact_swiggy_orders
    Group By
        case
            when price_inr < 100 THEN 'Under 100'
            when price_inr BETWEEN 100 AND 199 THEN '100 - 199'
            when price_inr BETWEEN 200 AND 299 THEN '200 - 299'
            when price_inr BETWEEN 300 AND 499 THEN '300 - 499'
            Else '500+'
        END
    Order by total_orders Desc

-- Rating Count Distribution(1-5)
select Rating,COUNT(*) as rating_count from fact_swiggy_orders
group by Rating
order by rating_count Desc























