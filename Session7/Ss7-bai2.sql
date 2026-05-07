-- BAI 2 - Bao cao "Bien mat" cua phong Dao tao
-- Derived Table la ket qua tam thoi duoc tao ra tu 1 subquery dat trong menh de FROM.
-- Trong FROM, moi bang/nguon du lieu can ten de SQL engine tham chieu cot,
-- lap ke hoach thuc thi va phan biet voi cac bang khac. Vi vay derived table bat buoc
-- phai co alias; neu khong co se loi: "Every derived table must have its own alias".
--
-- Bao cao tong tien thu duoc tu nhom hoc vien VIP
-- (VIP: tong chi tieu ca nhan > 10,000,000).
SELECT SUM(vip.total_spent) AS total_revenue_from_vip
FROM (
    SELECT student_id, SUM(amount) AS total_spent
    FROM Payments
    GROUP BY student_id
    HAVING SUM(amount) > 10000000
) AS vip;
