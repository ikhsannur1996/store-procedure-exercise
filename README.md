Sure, here's an exercise related to the topic of creating a stored procedure in a database:

## Exercise: Create a Stored Procedure

### Task:

Create a stored procedure named `UpdateProductPrice` in a database system of your choice. The procedure should take two parameters: `product_id` (INT) and `new_price` (DECIMAL). The purpose of the procedure is to update the price of a product identified by its ID.

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

- Replace `products` with the actual table name in your database.
- Ensure proper error handling and validation in the procedure for real-world scenarios.
- Test the procedure with various product IDs and prices to ensure its reliability.

### Conclusion:

Creating stored procedures adds flexibility and efficiency to database operations. This exercise helps reinforce your understanding of stored procedure creation and usage in a practical context.
