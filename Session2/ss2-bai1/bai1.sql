CREATE database Session2;

use Session2;

-- Sai lệch tiền → do dùng FLOAT
-- Tốn bộ nhớ → do dùng CHAR
-- Cách sửa:
-- Tiền → DECIMAL
-- Chuỗi → VARCHAR

CREATE TABLE Products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    description VARCHAR(500),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
