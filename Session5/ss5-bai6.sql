-- Bai 6: Module "Sieu Cong Cu Soi Don" cho Admin

-- [1) Ban ve logic - Mo xe bay toan tu OR]
-- - Bay pho bien: tron OR voi cac dieu kien khac nhung khong gom ngoac.
--   Vi du viet sai:
--   total_amount BETWEEN 2000000 AND 5000000
--   AND status <> 'CANCELLED'
--   AND note LIKE '%gap%'
--   OR user_id IS NULL
-- - Do uu tien toan tu, SQL hieu thanh:
--   ((A AND B AND C) OR D)
--   => chi can D dung (user_id IS NULL) la ban ghi duoc lay,
--      ke ca status = 'CANCELLED' hoac total_amount nam ngoai khoang.
-- - Ky thuat khoa bay: dung dau ngoac tron () de nhom bo loc kep:
--   A AND B AND (C OR D)

-- [2) Quy trinh chong bay dau vao phan trang]
-- - Cong thuc OFFSET:
--   offset = (page - 1) * page_size
-- - Voi yeu cau "Trang 3, moi trang 20 dong":
--   offset = (3 - 1) * 20 = 40
-- - Backend if/else de chan page loi:
--   1) Neu page IS NULL hoac khong phai so nguyen -> bao loi 400.
--   2) Neu page <= 0 -> gan page = 1 (hoac bao loi 400 tuy chinh sach API).
--   3) Neu page_size <= 0 -> gan page_size = 20.
--   4) Tinh offset = (page - 1) * page_size, roi bind vao SQL parameter.

-- [3) SQL duy nhat - dap ung day du nghiep vu] (MySQL 8.0.45)
SELECT
    order_id,
    user_id,
    total_amount,
    status,
    note,
    created_at,
    CASE
        WHEN total_amount > 4000000 THEN 'Nguy hiểm'
        ELSE 'Bình thường'
    END AS Alert_Level
FROM Orders
WHERE total_amount BETWEEN 2000000 AND 5000000
  AND status <> 'CANCELLED'
  AND (
      note LIKE '%gấp%'
      OR user_id IS NULL
  )
ORDER BY total_amount DESC
LIMIT 20 OFFSET 40;
