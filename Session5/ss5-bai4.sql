-- Bai 4: Toi uu bo loc "Don hang that bai"

-- [Giai phap 1] Dung nhieu dau "=" ket hop OR:
SELECT order_id, customer_id, restaurant_id, fail_reason, created_at
FROM Orders
WHERE fail_reason = 'KHACH_HUY'
   OR fail_reason = 'QUAN_DONG_CUA'
   OR fail_reason = 'KHONG_CO_TAI_XE'
   OR fail_reason = 'BOM_HANG';

-- [Giai phap 2] Dung toan tu tap hop IN (...):
SELECT order_id, customer_id, restaurant_id, fail_reason, created_at
FROM Orders
WHERE fail_reason IN ('KHACH_HUY', 'QUAN_DONG_CUA', 'KHONG_CO_TAI_XE', 'BOM_HANG');

-- [So sanh OR vs IN theo 3 tieu chi]
-- 1) Muc do code sach:
--    - OR: Lap dieu kien, dai dong, kho doc khi danh sach lon.
--    - IN: Ngan gon, de doc, nhin vao la thay bo gia tri loc.
-- 2) Kha nang mo rong (neu len 20 nguyen nhan):
--    - OR: Sua code nhieu, de sot, kho maintain.
--    - IN: Chi can them gia tri vao danh sach, de maintain hon ro ret.
-- 3) Hieu nang bien dich toi uu SQL Engine:
--    - OR: Engine van co the toi uu, nhung parse/cau query dai hon.
--    - IN: Thuong duoc rewrite/toi uu tot, query ngan gon hon ve mat bieu dien.
-- => Voi bai toan loc nhieu gia tri cung 1 cot, IN la lua chon tot hon.

-- [Bay du lieu] Neu backend nhan mang rong:
-- - Tuyet doi KHONG tao SQL: "WHERE fail_reason IN ()" (sai syntax).
-- - Logic chan o Backend:
--   1) Neu list_reason IS NULL hoac list_reason.size() = 0:
--      - Tra ve danh sach rong ngay lap tuc (khuyen nghi),
--        hoac bo qua query va thong bao "khong co tieu chi loc".
--   2) Nguoc lai:
--      - Tao placeholders theo so phan tu list_reason va bind parameter an toan.

-- [Query chot de dung] (giai phap tot nhat: IN + parameterized):
SELECT order_id, customer_id, restaurant_id, fail_reason, created_at
FROM Orders
WHERE fail_reason IN (?, ?, ?, ?);

-- Ghi chu:
-- - Trong code that te, so dau ? la dong theo do dai list_reason.
-- - Khong noi chuoi truc tiep de tranh SQL Injection.
