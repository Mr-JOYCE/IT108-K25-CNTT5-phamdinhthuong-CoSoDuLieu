-- Nguyen nhan loi:
-- LIMIT chi gioi han so dong tra ve, KHONG dam bao thu tu.
-- Neu khong co ORDER BY, MySQL co the tra ve 5 dong "bat ky"
-- tuy theo execution plan, index, cache... nen ket qua refresh bi thay doi.

-- Cau lenh dung de lay Top 5 quan moi nhat:
SELECT restaurant_name, created_at
FROM Restaurants
ORDER BY created_at DESC
LIMIT 5;
