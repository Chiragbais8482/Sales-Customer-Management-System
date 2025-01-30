-- 1. Create the Database
CREATE DATABASE IF NOT EXISTS SalesDB;
USE SalesDB;

-- 2. Create Tables

-- Customers Table
CREATE TABLE IF NOT EXISTS Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products Table
CREATE TABLE IF NOT EXISTS Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL
);

-- Orders Table
CREATE TABLE IF NOT EXISTS Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),
    status ENUM('Pending', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Order_Details Table
CREATE TABLE IF NOT EXISTS Order_Details (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    subtotal DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Payments Table
CREATE TABLE IF NOT EXISTS Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('Credit Card', 'PayPal', 'Bank Transfer'),
    status ENUM('Pending', 'Completed', 'Failed') DEFAULT 'Pending',
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- 3. Insert Sample Data

-- Customers
INSERT INTO Customers (name, email, phone, address) VALUES
('John Doe', 'john@example.com', '1234567890', '123 Main St'),
('Jane Smith', 'jane@example.com', '9876543210', '456 Oak St');

-- Products
INSERT INTO Products (name, category, price, stock_quantity) VALUES
('Laptop', 'Electronics', 800.00, 10),
('Smartphone', 'Electronics', 500.00, 15),
('Headphones', 'Accessories', 50.00, 30);

-- Orders
INSERT INTO Orders (customer_id, total_amount, status) VALUES
(1, 850.00, 'Pending'),
(2, 550.00, 'Shipped');

-- Order_Details
INSERT INTO Order_Details (order_id, product_id, quantity, subtotal) VALUES
(1, 1, 1, 800.00),
(1, 3, 1, 50.00),
(2, 2, 1, 500.00);

-- Payments
INSERT INTO Payments (order_id, amount, payment_method, status) VALUES
(1, 850.00, 'Credit Card', 'Completed'),
(2, 550.00, 'PayPal', 'Completed');

-- 4. Create Stored Procedure for Adding a New Order
DELIMITER $$

CREATE PROCEDURE AddOrder(
    IN cust_id INT, IN prod_id INT, IN qty INT
)
BEGIN
    DECLARE prod_price DECIMAL(10,2);
    DECLARE total DECIMAL(10,2);
    
    -- Get product price
    SELECT price INTO prod_price FROM Products WHERE product_id = prod_id;
    
    -- Calculate total amount
    SET total = prod_price * qty;
    
    -- Insert order
    INSERT INTO Orders (customer_id, total_amount, status) VALUES (cust_id, total, 'Pending');
    
    -- Get the last inserted order_id
    SET @order_id = LAST_INSERT_ID();
    
    -- Insert order details
    INSERT INTO Order_Details (order_id, product_id, quantity, subtotal) VALUES (@order_id, prod_id, qty, total);
    
END $$

DELIMITER ;

-- 5. Create Indexes for Faster Querying
CREATE INDEX idx_customer_email ON Customers(email);
CREATE INDEX idx_order_status ON Orders(status);

-- End of Script
