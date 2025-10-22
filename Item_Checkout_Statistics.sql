-- Current version is Sept 2025 checkouts for lcrsv and lccrs, update lines 42 and 43 for other months/locations.

SELECT 
    'i' || 
    rm.record_num::text ||
    CASE
        WHEN (
            (substring(rm.record_num::text from 7 for 1)::int * 2 +
             substring(rm.record_num::text from 6 for 1)::int * 3 +
             substring(rm.record_num::text from 5 for 1)::int * 4 +
             substring(rm.record_num::text from 4 for 1)::int * 5 +
             substring(rm.record_num::text from 3 for 1)::int * 6 +
             substring(rm.record_num::text from 2 for 1)::int * 7 +
             substring(rm.record_num::text from 1 for 1)::int * 8 
            ) % 11) = 10 THEN 'x'
        ELSE (
            (substring(rm.record_num::text from 7 for 1)::int * 2 +
             substring(rm.record_num::text from 6 for 1)::int * 3 +
             substring(rm.record_num::text from 5 for 1)::int * 4 +
             substring(rm.record_num::text from 4 for 1)::int * 5 +
             substring(rm.record_num::text from 3 for 1)::int * 6 +
             substring(rm.record_num::text from 2 for 1)::int * 7 +
             substring(rm.record_num::text from 1 for 1)::int * 8 
            ) % 11)::text
    END AS "Item Number",
	brp.best_title AS "Title",
	i.location_code AS "Location Code",
	COUNT(*) AS "Checkouts"
	
FROM sierra_view.item_record i
JOIN sierra_view.record_metadata rm
    ON rm.id = i.record_id
JOIN sierra_view.item_circ_history ich
    ON ich.item_record_metadata_id = rm.id
JOIN sierra_view.bib_record_item_record_link bil
	ON bil.item_record_id = i.id
JOIN sierra_view.bib_record b
	ON bil.bib_record_id = b.id
JOIN sierra_view.bib_record_property brp
	ON brp.bib_record_id = b.id
	
WHERE ich.checkout_gmt BETWEEN '2025-09-01' AND '2025-09-30'
  AND i.location_code IN ('lcrsv', 'lccrs')

GROUP BY rm.record_num, i.location_code, brp.best_title
ORDER BY "Item Number" DESC;
