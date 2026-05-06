SELECT
    u.name AS customer_name,
    h.star_rating,
    SUM(b.total_price) AS total_spent
FROM Bookings b
JOIN Users u ON u.user_id = b.user_id
JOIN Hotels h ON h.hotel_id = b.hotel_id
WHERE b.status = 'COMPLETED'
  AND b.total_price > 0
GROUP BY u.user_id, u.name, h.star_rating
HAVING SUM(b.total_price) > 50000000
ORDER BY h.star_rating DESC, total_spent DESC, u.name ASC;
