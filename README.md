# swiggy-sql-data-analysis
SQL and data analysis project based on Swiggy dataset using SQL queries and CSV data.


# Swiggy SQL Data Analysis Project

## Project Objective
The objective of this project is to analyze Swiggy food delivery data using SQL queries and data analysis techniques to generate meaningful business insights related to sales, customers, restaurants, and delivery performance.

---

# Business Questions Solved

- Which restaurants generate the highest orders and revenue?
- What are the most popular food categories?
- Which cities or locations have maximum orders?
- What are the peak ordering hours?
- Which customers place the most orders?
- How does delivery performance impact customer experience?
- What are the sales and order trends over time?

---

# Detailed Description of Data

The project uses Swiggy dataset stored in CSV format and analyzed using SQL queries.

## Dataset Files
- `Swiggy_Data.csv`
- `Swiggy project.sql`

The dataset includes:
- Customer information
- Restaurant details
- Food categories
- Order records
- Delivery information
- Sales and revenue data
- Ratings and reviews

---

# Technical Tools Used

- SQL
- CSV Dataset
- Data Analysis
- Query Optimization
- Relational Data Analysis

---

# Detailed Steps Followed

1. Imported the Swiggy dataset into the SQL environment.
2. Cleaned and formatted the data.
3. Created SQL queries for business analysis.
4. Performed aggregations and filtering operations.
5. Analyzed customer and restaurant performance.
6. Generated sales and order insights.
7. Optimized queries for better performance.
8. Extracted meaningful business metrics.

---

# Challenges Faced

- Handling missing and duplicate data.
- Writing optimized SQL queries.
- Managing large transactional datasets.
- Creating accurate aggregations and joins.
- Extracting meaningful business insights from raw data.

---

# Outcome / Outputs

The project provides:
- Restaurant performance analysis
- Customer behavior insights
- Sales trend analysis
- Food category analysis
- Delivery performance insights
- Business intelligence reports

---

# Business Impact

This project helps businesses:
- Understand customer ordering behavior
- Improve restaurant performance tracking
- Optimize food delivery operations
- Increase operational efficiency
- Support business decision-making using data insights

---

# Detailed Presentation

The SQL analysis provides structured business insights through optimized queries and analytical reporting on Swiggy operational data.

---

# Query Examples

```sql
SELECT restaurant_name, COUNT(order_id) AS total_orders
FROM swiggy_data
GROUP BY restaurant_name
ORDER BY total_orders DESC;
