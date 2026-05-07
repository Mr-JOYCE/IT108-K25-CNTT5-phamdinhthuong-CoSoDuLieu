-- BAI 5 - Bao cao "Do Lech Hoc Phi"
-- Giai phap kien truc:
-- Dat Scalar Subquery trong SELECT de lay 1 gia tri tong quan (AVG gia toan san)
-- roi tai su dung gia tri do cho TUNG dong khoa hoc.
-- Nho vay ket qua van giu chi tiet theo moi course (title, price),
-- dong thoi van co thong tin tong quan de tinh do lech.
-- Khac voi GROUP BY (de gom nhom), cach nay khong lam mat chi tiet tung khoa hoc.
--
-- Bao cao 3 cot theo yeu cau giam doc.
SELECT
    c.title,
    c.price,
    c.price - (
        SELECT AVG(price)
        FROM Courses
    ) AS Price_Difference
FROM Courses c;
