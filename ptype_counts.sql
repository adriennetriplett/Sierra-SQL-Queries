SELECT 
    p.ptype_code AS "P-Type Code",
    ptn.description AS "P-Type Description",
    COUNT(*) AS "Total Patrons",
    COUNT(CASE WHEN p.expiration_date_gmt >= CURRENT_DATE THEN 1 END) AS "Patrons Not Expired",
    COUNT(CASE WHEN p.owed_amt > 0 THEN 1 END) AS "Patrons With Fines"
	
FROM sierra_view.patron_record p
JOIN sierra_view.ptype_property_name ptn
    ON ptn.ptype_id = p.ptype_code + 1
	
GROUP BY p.ptype_code, ptn.description
ORDER BY p.ptype_code;
