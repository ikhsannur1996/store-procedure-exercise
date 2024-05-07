# Exercise: Create a Stored Procedure

## Objective:
Design a stored procedure to transfer data from a transactional database to a staging area, then load it into a data warehouse (fact and dimension tables), and datamart.

## Requirements:
- Basic understanding of SQL
- Access to a database management system (DBMS) such as PostgreSQL, etc.

## Task:
Design a stored procedure named `dwh.generate_employee()` to perform the following tasks:
1. Transfer data from the transactional database tables to corresponding staging tables.
2. Load data from staging tables into appropriate dimension tables in the data warehouse.
3. Load data from staging tables into appropriate fact tables in the data warehouse.
5. Provide clear documentation within the stored procedure.

### Steps to Follow:

1. **Connect to Database**: Use your preferred method to connect to the database system where you want to create the stored procedure.

2. **Write SQL Procedure**: Write the SQL script for the stored procedure. Ensure it accepts the specified parameters and updates the product price accordingly.

3. **Execute Script**: Execute the SQL script to create the stored procedure in the database.

4. **Test Procedure**: Test the procedure by calling it with sample product IDs and new prices.

5. **Verify Results**: Check if the product prices were updated correctly in the database.

### Example SQL Script:

```sql
-- Create the stored procedure
CREATE PROCEDURE UpdateProductPrice (IN product_id INT, IN new_price DECIMAL)
BEGIN
    UPDATE products SET price = new_price WHERE id = product_id;
END
```

### Notes:
- Ensure proper error handling and validation in the procedure for real-world scenarios.
- Test the procedure  to ensure its reliability.

### Conclusion:

Creating stored procedures adds flexibility and efficiency to database operations. This exercise helps reinforce your understanding of stored procedure creation and usage in a practical context.
