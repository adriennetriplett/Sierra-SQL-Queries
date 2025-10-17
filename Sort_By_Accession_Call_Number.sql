WITH review_items AS (
    SELECT bs.record_metadata_id
    FROM sierra_view.bool_set bs
    JOIN sierra_view.bool_info bi 
        ON bs.bool_info_id = bi.id
    WHERE bi.id = :review_id
),
src AS (
  SELECT
    regexp_replace(
      btrim(COALESCE(irp.call_number, irp.call_number_norm)),
      '(\||\$)[a-zA-Z]',
      '',
      'g'
    ) AS clean_callnum,
    regexp_replace(
      irp.call_number,
      '(\||\$)[a-zA-Z]',
      '',
      'g'
    ) AS original_callnum,
    irp.item_record_id
  FROM review_items ri
  JOIN sierra_view.item_record_property irp
    ON irp.item_record_id = ri.record_metadata_id
)
SELECT 
    'b' ||
    brm.record_num::text ||
    CASE
        WHEN (
            (substring(brm.record_num::text from 7 for 1)::int * 2 +
             substring(brm.record_num::text from 6 for 1)::int * 3 +
             substring(brm.record_num::text from 5 for 1)::int * 4 +
             substring(brm.record_num::text from 4 for 1)::int * 5 +
             substring(brm.record_num::text from 3 for 1)::int * 6 +
             substring(brm.record_num::text from 2 for 1)::int * 7 +
             substring(brm.record_num::text from 1 for 1)::int * 8 
            ) % 11) = 10 THEN 'x'
        ELSE (
            (substring(brm.record_num::text from 7 for 1)::int * 2 +
             substring(brm.record_num::text from 6 for 1)::int * 3 +
             substring(brm.record_num::text from 5 for 1)::int * 4 +
             substring(brm.record_num::text from 4 for 1)::int * 5 +
             substring(brm.record_num::text from 3 for 1)::int * 6 +
             substring(brm.record_num::text from 2 for 1)::int * 7 +
             substring(brm.record_num::text from 1 for 1)::int * 8 
            ) % 11)::text
  	END AS "Bib Record",
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
  	END AS "Item Record",
    src.original_callnum AS "Call Number", 
	brp.best_title AS "Title",
	ir.location_code AS "Location",
	ir.item_status_code AS "Item Status Code",
	ir.icode2 AS "Item Code 2",
	br.bcode3 AS "Bib Code 3",
	irp.barcode AS "Barcode"
FROM src
JOIN sierra_view.item_record ir
	ON ir.id = src.item_record_id
JOIN sierra_view.item_record_property irp
	ON irp.item_record_id = ir.id
JOIN sierra_view.record_metadata rm
	ON rm.id = ir.record_id
JOIN sierra_view.bib_record_item_record_link brl
	ON brl.item_record_id = ir.id
JOIN sierra_view.bib_record br
	ON br.id = brl.bib_record_id
JOIN sierra_view.bib_record_property brp
	ON brp.bib_record_id = br.id
JOIN sierra_view.record_metadata brm
	ON brm.id = br.id	
LEFT JOIN sierra_view.volume_record_item_record_link vi
	ON vi.item_record_id = ir.id
LEFT JOIN sierra_view.volume_record vr
	ON vi.volume_record_id = vr.id
ORDER BY 
    CASE
      WHEN substring(src.clean_callnum FROM '^\s*(\d+)') IS NOT NULL
        THEN substring(src.clean_callnum FROM '^\s*(\d+)')::BIGINT
      ELSE NULL
    END ASC NULLS LAST,
    COALESCE(
      NULLIF(substring(src.clean_callnum FROM '^\s*(\d+)'), ''),
      src.clean_callnum
    ) ASC;
