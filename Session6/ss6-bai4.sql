SELECT hotel_id
FROM Bookings
WHERE status = 'COMPLETED'
GROUP BY hotel_id
HAVING COUNT(*) >= 50
   AND AVG(total_price) > 3000000;
