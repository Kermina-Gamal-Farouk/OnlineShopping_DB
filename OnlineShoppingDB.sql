
IF DB_ID('OnlineShopping') IS NOT NULL
BEGIN
    ALTER DATABASE OnlineShopping SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE OnlineShopping;
END
GO
CREATE DATABASE OnlineShopping;
GO
USE OnlineShopping;
GO

-- ---------- Tables ----------
CREATE TABLE Product (
    ProductID INT PRIMARY KEY NOT NULL,
    Pname     VARCHAR(100),
    Price     DECIMAL(10, 2)
);

CREATE TABLE Customer (
    CustomerID  INT PRIMARY KEY NOT NULL,
    Name        VARCHAR(30),
    City        VARCHAR(19),
    Street      VARCHAR(25),
    Home_number VARCHAR(20)
);

CREATE TABLE Customer_Phone (
    CustomerID     INT,
    Customer_phone VARCHAR(20),
    PRIMARY KEY (CustomerID, Customer_phone),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE Orders (
    OrderID      INT PRIMARY KEY NOT NULL,
    Total_amount DECIMAL(10, 2),
    Order_date   DATE,
    CustomerID   INT,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE Shipping (
    ShippingID              INT PRIMARY KEY NOT NULL,
    Shipping_method         VARCHAR(35),
    Shipping_cost           DECIMAL(10, 2),
    Estimated_delivery_date DATE,
    OrderID                 INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

CREATE TABLE Order_Items (
    Quantity  INT,
    ProductID INT,
    OrderID   INT,
    PRIMARY KEY (ProductID, OrderID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    FOREIGN KEY (OrderID)   REFERENCES Orders(OrderID)
);
GO

-- ---------- Data ----------
INSERT INTO Product (ProductID, Pname, Price) VALUES
(1, 'Phone',      5000.00),
(2, 'Laptop',    15000.00),
(3, 'Headphones',  800.00),
(4, 'Tablet',     7000.00);

INSERT INTO Customer (CustomerID, Name, City, Street, Home_number) VALUES
(1, 'Ahmed Ali',    'Cairo',      'Tahrir',      '101'),
(2, 'Sara Mohamed', 'Alexandria', 'El Gomhoria', '205'),
(3, 'Omar Hassan',  'Giza',       '6th October', '32'),
(4, 'Nour Said',    'Aswan',      'Nile Street', '10');

INSERT INTO Customer_Phone (CustomerID, Customer_phone) VALUES
(1, '01112345678'),
(1, '01234567891'),
(2, '01098765432'),
(3, '01555555555');

INSERT INTO Orders (OrderID, Total_amount, Order_date, CustomerID) VALUES
(1,  5800.00, '2023-05-01', 1),
(2, 15000.00, '2023-05-03', 2),
(3,  7000.00, '2023-05-05', 3),
(4,   800.00, '2023-05-07', 4);

INSERT INTO Shipping (ShippingID, Shipping_method, Shipping_cost, Estimated_delivery_date, OrderID) VALUES
(1, 'Express',  100.00, '2023-05-05', 1),
(2, 'Standard',  50.00, '2023-05-10', 2),
(3, 'Express',  120.00, '2023-05-09', 3),
(4, 'Standard',  40.00, '2023-05-11', 4);

-- Order 4 (total 800) = 1 Headphones, added so every order has items
INSERT INTO Order_Items (Quantity, ProductID, OrderID) VALUES
(1, 1, 1),
(1, 3, 1),
(1, 2, 2),
(1, 4, 3),
(1, 3, 4);
GO


-- 1) Orders with customer name and date
SELECT o.OrderID, c.Name, o.Order_date, o.Total_amount
FROM Orders o JOIN Customer c ON c.CustomerID = o.CustomerID;

-- 2) Products inside each order
SELECT o.OrderID, p.Pname, oi.Quantity, p.Price * oi.Quantity AS LineTotal
FROM Order_Items oi
JOIN Orders  o ON o.OrderID   = oi.OrderID
JOIN Product p ON p.ProductID = oi.ProductID
ORDER BY o.OrderID;

-- 3) Customers with all their phone numbers
SELECT c.Name, cp.Customer_phone
FROM Customer c LEFT JOIN Customer_Phone cp ON cp.CustomerID = c.CustomerID;

-- 4) Orders with shipping method and final cost (items + shipping)
SELECT o.OrderID, s.Shipping_method, o.Total_amount + s.Shipping_cost AS GrandTotal
FROM Orders o JOIN Shipping s ON s.OrderID = o.OrderID;

-- 5) Total spent per customer
SELECT c.Name, SUM(o.Total_amount) AS TotalSpent
FROM Customer c JOIN Orders o ON o.CustomerID = c.CustomerID
GROUP BY c.Name ORDER BY TotalSpent DESC;

-- 6) Best-selling products
SELECT p.Pname, SUM(oi.Quantity) AS SoldQty
FROM Product p JOIN Order_Items oi ON oi.ProductID = p.ProductID
GROUP BY p.Pname ORDER BY SoldQty DESC;
