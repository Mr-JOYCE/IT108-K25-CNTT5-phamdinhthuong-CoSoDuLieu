-- BAI 4 - Tham hoa "Black Friday"
-- Kham nghiem (Boolean Logic):
-- x NOT IN (1, 2, NULL)
-- <=> (x <> 1) AND (x <> 2) AND (x <> NULL)
-- Trong SQL, moi so sanh voi NULL (vd: x <> NULL) cho ra UNKNOWN.
-- TRUE AND TRUE AND UNKNOWN = UNKNOWN (khong phai TRUE),
-- ma menh de WHERE chi giu lai dong co ket qua TRUE.
-- Vi vay cac dong deu bi loai, dan den ket qua rong.
--
-- Giai phap kien truc:
-- Neu van dung NOT IN, phai loc rac NULL ngay trong subquery: course_id IS NOT NULL.
SELECT *
FROM Courses
WHERE id NOT IN (
    SELECT course_id
    FROM Enrollments
    WHERE course_id IS NOT NULL
);

-- Cach an toan tuyet doi (khuyen nghi production): dung NOT EXISTS
-- vi khong bi bay NULL semantics cua NOT IN.
-- SELECT c.*
-- FROM Courses c
-- WHERE NOT EXISTS (
--     SELECT 1
--     FROM Enrollments e
--     WHERE e.course_id = c.id
-- );
