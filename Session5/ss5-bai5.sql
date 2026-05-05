-- Bai 5: Tool "Danh nhan Khach Hang Tu Dong" (Auto Tagging)

-- [Giai phap kien truc]
-- - Su dung CASE WHEN ... THEN ... ELSE ... END trong menh de SELECT
--   de re nhanh logic va tao cot ao "Xep_Hang" ngay luc truy van.
-- - De xu ly du lieu NULL an toan, dung COALESCE(total_orders, 0)
--   de quy doi NULL ve 0 truoc khi danh gia dieu kien.

-- [Luong xu ly NULL]
-- 1) Neu total_orders la NULL (khach moi chua phat sinh don):
--    COALESCE(total_orders, 0) -> 0.
-- 2) Gia tri 0 se roi vao nhanh "< 100" -> nhan "Bac".
-- 3) Dam bao khong bi sai logic, khong phat sinh loi khi bao cao tong hop.

-- [Code hoan chinh] (MySQL 8.0.45)
SELECT
    user_name AS Ten_Khach_Hang,
    CASE
        WHEN COALESCE(total_orders, 0) > 500 THEN 'Kim Cương'
        WHEN COALESCE(total_orders, 0) BETWEEN 100 AND 500 THEN 'Vàng'
        ELSE 'Bạc'
    END AS Xep_Hang
FROM Users;
