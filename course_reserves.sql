SELECT 
    -- Item record number with check digit
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

    brp.best_title AS "Title",
    i.location_code AS "Location Code",

    -- Course record number with check digit
    'r' || 
    crm.record_num::text ||
    CASE
        WHEN (
            (substring(crm.record_num::text from 7 for 1)::int * 2 +
             substring(crm.record_num::text from 6 for 1)::int * 3 +
             substring(crm.record_num::text from 5 for 1)::int * 4 +
             substring(crm.record_num::text from 4 for 1)::int * 5 +
             substring(crm.record_num::text from 3 for 1)::int * 6 +
             substring(crm.record_num::text from 2 for 1)::int * 7 +
             substring(crm.record_num::text from 1 for 1)::int * 8
            ) % 11) = 10 THEN 'x'
        ELSE (
            (substring(crm.record_num::text from 7 for 1)::int * 2 +
             substring(crm.record_num::text from 6 for 1)::int * 3 +
             substring(crm.record_num::text from 5 for 1)::int * 4 +
             substring(crm.record_num::text from 4 for 1)::int * 5 +
             substring(crm.record_num::text from 3 for 1)::int * 6 +
             substring(crm.record_num::text from 2 for 1)::int * 7 +
             substring(crm.record_num::text from 1 for 1)::int * 8
            ) % 11)::text
        END AS "Course Record",

    vr.field_content AS "Course Name/Number",

    -- Aggregate all Prof/Instructor values per course record
    string_agg(vp.field_content, '; ') AS "Prof/Instructor",

    to_char(c.begin_date, 'MM-DD-YYYY') AS "Begin Date",
    to_char(c.end_date, 'MM-DD-YYYY') AS "End Date"

FROM sierra_view.item_record i
JOIN sierra_view.record_metadata rm
    ON rm.id = i.record_id

JOIN sierra_view.course_record_item_record_link cil
    ON cil.item_record_id = i.id

LEFT JOIN sierra_view.course_record c
    ON cil.course_record_id = c.id

JOIN sierra_view.record_metadata crm
    ON crm.id = cil.course_record_id

JOIN sierra_view.bib_record_item_record_link bil
    ON bil.item_record_id = i.id
JOIN sierra_view.bib_record b
    ON bil.bib_record_id = b.id
JOIN sierra_view.bib_record_property brp
    ON brp.bib_record_id = b.id

LEFT JOIN sierra_view.varfield_view vr
    ON vr.record_id = crm.id
    AND vr.varfield_type_code = 'r'

LEFT JOIN sierra_view.varfield_view vp
    ON vp.record_id = crm.id
    AND vp.varfield_type_code = 'p'

GROUP BY 
    rm.record_num,
    i.location_code,
    brp.best_title,
    crm.record_num,
    vr.field_content,
    c.begin_date,
    c.end_date

ORDER BY "Item Record" DESC;
