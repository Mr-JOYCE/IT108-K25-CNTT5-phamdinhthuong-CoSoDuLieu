SELECT hotel_id, MIN(price_per_night) AS min_price
FROM Rooms
GROUP BY hotel_id;
