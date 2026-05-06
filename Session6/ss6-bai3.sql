SELECT 
    user_id,
    COUNT(*) AS total_bookings,
    SUM(CASE 
            WHEN status = 'CANCELLED' THEN 1 
            ELSE 0 
        END) AS cancelled_bookings
FROM bookings
GROUP BY user_id
HAVING 
    COUNT(*) >= 10
    AND SUM(CASE 
                WHEN status = 'CANCELLED' THEN 1 
                ELSE 0 
            END) > 5;