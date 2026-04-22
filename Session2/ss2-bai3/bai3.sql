use Session2;

CREATE TABLE ORDERS (
    OrderID INT PRIMARY KEY,
    OrderDate DATE NOT NULL DEFAULT (CURRENT_DATE),
    TotalAmount DECIMAL(18,2) NOT NULL CHECK (TotalAmount >= 0),
    CustomerID INT NOT NULL,
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID)
        REFERENCES CUSTOMERS(CustomerID)
);

