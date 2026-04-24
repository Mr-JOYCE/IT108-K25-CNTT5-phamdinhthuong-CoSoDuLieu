CREATE DATABASE ShopManager;
USE ShopManager;

CREATE TABLE Categories (
	category_id INT unique primary key auto_increment,
    category_name varchar(100)
);

CREATE TABLE Products (
	product_id INT primary KEY auto_increment,
    product_name varchar(100) not null,
    price INT ,
    stock INT,
    category_id INT,
    foreign key (category_id) references Categories(category_id)
);

INSERT INTO Categories (category_id, category_name)
value (1, 'Điện tử'), (2, 'Thời trang');

insert into Products (product_id, product_name, price, stock, category_id)
value
(1, 'iPhone 15', 25000000, 10, 1),
(2, 'Samsung S23', 20000000, 5, 1),
(3, 'Áo sơ mi nam', 500000, 50, 2),
(4, 'Giày thể thao', 1200000, 20, 2);

UPDATE Products
set price = 26000000
where product_id = 1;

update Products
set stock = stock + 10;

delete from Products 
where product_id = 4;

select * from Product;

select product_name from Products
where stock > 15;

		