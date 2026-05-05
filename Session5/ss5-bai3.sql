-- [I/O] Dau vao can co o Backend:
-- - min_trust_score: nguong toi thieu tu cau hinh he thong (so nguyen/so thuc).
-- - status_mac_dinh: 'AVAILABLE' (co the hard-code theo nghiep vu).
-- - (Tuy chon) gioi_han_so_luong_tai_xe can tra ve, vi du LIMIT 20.

-- [Luong xu ly Backend - chan bay diem am truoc khi goi SQL]:
-- 1) Doc min_trust_score tu config.
-- 2) Neu min_trust_score IS NULL hoac khong phai so -> dung xu ly, bao loi cau hinh.
-- 3) Neu min_trust_score < 0 -> dung xu ly, bao loi "min_trust_score khong duoc am".
-- 4) Nguoc lai, dung nguong_hop_le = GREATEST(min_trust_score, 80)
--    de dam bao van tuan thu nghiep vu "trust_score >= 80".
-- 5) Truyen nguong_hop_le vao SQL parameter va thuc thi query.

-- SQL (MySQL 8.0.45) - loc va sap xep driver matching:
SELECT
    driver_id,
    driver_name,
    status,
    trust_score,
    distance_km
FROM Drivers
WHERE status = 'AVAILABLE'
  AND trust_score >= ?
ORDER BY distance_km ASC, trust_score DESC;

-- Ghi chu:
-- - Gia tri "?" la parameter nguong_hop_le da duoc validate o Backend.
-- - Neu can gioi han so ket qua: them "LIMIT ?".
