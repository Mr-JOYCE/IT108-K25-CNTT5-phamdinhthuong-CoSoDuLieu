SELECT city, SUM(total_price) AS revenue
FROM Bookings
WHERE status = 'COMPLETED'
GROUP BY city
HAVING SUM(total_price) > 0;
