-- BAI 1 - Sua loi "Subquery returns more than 1 row"
-- Phan tich:
-- Toan tu "=" yeu cau so sanh 1 gia tri o ben trai voi DUNG 1 gia tri o ben phai.
-- Khi subquery tra ve nhieu dong (vi instructor_id = 5 co nhieu khoa hoc, nhieu muc gia),
-- bieu thuc "price = (subquery)" khong con hop le, dan den loi.
--
-- Cau truy van da sua:
-- Dung IN de so sanh price voi TAP cac muc gia cua giang vien 5.
SELECT title, price
FROM Courses
WHERE price IN (
    SELECT price
    FROM Courses
    WHERE instructor_id = 5
);
