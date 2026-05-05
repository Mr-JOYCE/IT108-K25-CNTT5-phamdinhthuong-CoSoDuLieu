-- Nguyen nhan loi:
-- Trong SQL, AND co do uu tien cao hon OR.
-- Cau sai se duoc hieu la:
-- district = 'Quan 1' OR (district = 'Quan 3' AND rating > 4.0)
-- => Moi nha hang o Quan 1 deu duoc lay, ke ca rating thap.

-- Cau lenh da va loi (MySQL 8.0.45):
SELECT restaurant_name, address, rating
FROM Restaurants
WHERE (district = 'Quận 1' OR district = 'Quận 3')
  AND rating > 4.0;
