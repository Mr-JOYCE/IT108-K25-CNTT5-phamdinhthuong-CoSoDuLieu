-- BAI 3 - Chien dich "Danh thuc Hoc vien Ngu dong"
-- Bao ve quan diem:
-- 1) NOT EXISTS dung correlated subquery va co co che short-circuit:
--    voi moi hoc vien, DB chi can tim THAY 1 dong payment nam 2024 la dung ngay
--    viec kiem tra (khong can quet het toan bo payment cua hoc vien do).
-- 2) Tren tap du lieu lon (5 trieu users), kha nang dung som nay giup giam I/O va CPU,
--    dac biet khi co index phu hop tren Payments(student_id, payment_date).
-- 3) NOT IN thuong kem loi the nay; ngoai ra con co rui ro logic voi NULL:
--    neu tap con co NULL, bieu thuc NOT IN co the tra ket qua khong nhu mong doi.
-- => Trong bai toan loc "chua tung mua nam 2024", NOT EXISTS an toan va hieu nang hon.
--
-- Danh sach email hoc vien "ngu dong":
-- Co tai khoan trong Students nhung KHONG ton tai giao dich Payments trong nam 2024.
SELECT s.email
FROM Students s
WHERE NOT EXISTS (
    SELECT 1
    FROM Payments p
    WHERE p.student_id = s.student_id
      AND p.payment_date >= '2024-01-01'
      AND p.payment_date < '2025-01-01'
);
