WITH review_bibs AS (
    SELECT
        bs.record_metadata_id
    FROM
        sierra_view.bool_set bs
    WHERE
        bs.bool_info_id = 407 /* -- UPDATE WITH THE DESIRED REVIEW FILE NUMBER -- */
),

/* -- Bibs with check digits -- */
bib_nums AS (
    SELECT
        brm.id AS record_metadata_id,
        'b' ||
        brm.record_num::text ||
        CASE
            WHEN (
                (substring(lpad(brm.record_num::text, 7, '0') from 7 for 1)::int * 2 +
                 substring(lpad(brm.record_num::text, 7, '0') from 6 for 1)::int * 3 +
                 substring(lpad(brm.record_num::text, 7, '0') from 5 for 1)::int * 4 +
                 substring(lpad(brm.record_num::text, 7, '0') from 4 for 1)::int * 5 +
                 substring(lpad(brm.record_num::text, 7, '0') from 3 for 1)::int * 6 +
                 substring(lpad(brm.record_num::text, 7, '0') from 2 for 1)::int * 7 +
                 substring(lpad(brm.record_num::text, 7, '0') from 1 for 1)::int * 8
                ) % 11
            ) = 10 THEN 'x'
            ELSE (
                (substring(lpad(brm.record_num::text, 7, '0') from 7 for 1)::int * 2 +
                 substring(lpad(brm.record_num::text, 7, '0') from 6 for 1)::int * 3 +
                 substring(lpad(brm.record_num::text, 7, '0') from 5 for 1)::int * 4 +
                 substring(lpad(brm.record_num::text, 7, '0') from 4 for 1)::int * 5 +
                 substring(lpad(brm.record_num::text, 7, '0') from 3 for 1)::int * 6 +
                 substring(lpad(brm.record_num::text, 7, '0') from 2 for 1)::int * 7 +
                 substring(lpad(brm.record_num::text, 7, '0') from 1 for 1)::int * 8
                ) % 11
            )::text
        END AS bib_record
    FROM sierra_view.record_metadata brm
),

/* -- Items with check digits -- */
item_nums AS (
    SELECT
        irm.id AS record_metadata_id,
        'i' ||
        irm.record_num::text ||
        CASE
            WHEN (
                (substring(lpad(irm.record_num::text, 7, '0') from 7 for 1)::int * 2 +
                 substring(lpad(irm.record_num::text, 7, '0') from 6 for 1)::int * 3 +
                 substring(lpad(irm.record_num::text, 7, '0') from 5 for 1)::int * 4 +
                 substring(lpad(irm.record_num::text, 7, '0') from 4 for 1)::int * 5 +
                 substring(lpad(irm.record_num::text, 7, '0') from 3 for 1)::int * 6 +
                 substring(lpad(irm.record_num::text, 7, '0') from 2 for 1)::int * 7 +
                 substring(lpad(irm.record_num::text, 7, '0') from 1 for 1)::int * 8
                ) % 11
            ) = 10 THEN 'x'
            ELSE (
                (substring(lpad(irm.record_num::text, 7, '0') from 7 for 1)::int * 2 +
                 substring(lpad(irm.record_num::text, 7, '0') from 6 for 1)::int * 3 +
                 substring(lpad(irm.record_num::text, 7, '0') from 5 for 1)::int * 4 +
                 substring(lpad(irm.record_num::text, 7, '0') from 4 for 1)::int * 5 +
                 substring(lpad(irm.record_num::text, 7, '0') from 3 for 1)::int * 6 +
                 substring(lpad(irm.record_num::text, 7, '0') from 2 for 1)::int * 7 +
                 substring(lpad(irm.record_num::text, 7, '0') from 1 for 1)::int * 8
                ) % 11
            )::text
        END AS item_record
    FROM sierra_view.record_metadata irm
),

/* -- Checkins / holdings with check digits -- */
checkin_nums AS (
    SELECT
        hrm.id AS record_metadata_id,
        'c' ||
        hrm.record_num::text ||
        CASE
            WHEN (
                (substring(lpad(hrm.record_num::text, 7, '0') from 7 for 1)::int * 2 +
                 substring(lpad(hrm.record_num::text, 7, '0') from 6 for 1)::int * 3 +
                 substring(lpad(hrm.record_num::text, 7, '0') from 5 for 1)::int * 4 +
                 substring(lpad(hrm.record_num::text, 7, '0') from 4 for 1)::int * 5 +
                 substring(lpad(hrm.record_num::text, 7, '0') from 3 for 1)::int * 6 +
                 substring(lpad(hrm.record_num::text, 7, '0') from 2 for 1)::int * 7 +
                 substring(lpad(hrm.record_num::text, 7, '0') from 1 for 1)::int * 8
                ) % 11
            ) = 10 THEN 'x'
            ELSE (
                (substring(lpad(hrm.record_num::text, 7, '0') from 7 for 1)::int * 2 +
                 substring(lpad(hrm.record_num::text, 7, '0') from 6 for 1)::int * 3 +
                 substring(lpad(hrm.record_num::text, 7, '0') from 5 for 1)::int * 4 +
                 substring(lpad(hrm.record_num::text, 7, '0') from 4 for 1)::int * 5 +
                 substring(lpad(hrm.record_num::text, 7, '0') from 3 for 1)::int * 6 +
                 substring(lpad(hrm.record_num::text, 7, '0') from 2 for 1)::int * 7 +
                 substring(lpad(hrm.record_num::text, 7, '0') from 1 for 1)::int * 8
                ) % 11
            )::text
        END AS checkin_record
    FROM sierra_view.record_metadata hrm
),

/* -- Orders with check digits -- */
order_nums AS (
    SELECT
        orm.id AS record_metadata_id,
        'o' ||
        orm.record_num::text ||
        CASE
            WHEN (
                (substring(lpad(orm.record_num::text, 7, '0') from 7 for 1)::int * 2 +
                 substring(lpad(orm.record_num::text, 7, '0') from 6 for 1)::int * 3 +
                 substring(lpad(orm.record_num::text, 7, '0') from 5 for 1)::int * 4 +
                 substring(lpad(orm.record_num::text, 7, '0') from 4 for 1)::int * 5 +
                 substring(lpad(orm.record_num::text, 7, '0') from 3 for 1)::int * 6 +
                 substring(lpad(orm.record_num::text, 7, '0') from 2 for 1)::int * 7 +
                 substring(lpad(orm.record_num::text, 7, '0') from 1 for 1)::int * 8
                ) % 11
            ) = 10 THEN 'x'
            ELSE (
                (substring(lpad(orm.record_num::text, 7, '0') from 7 for 1)::int * 2 +
                 substring(lpad(orm.record_num::text, 7, '0') from 6 for 1)::int * 3 +
                 substring(lpad(orm.record_num::text, 7, '0') from 5 for 1)::int * 4 +
                 substring(lpad(orm.record_num::text, 7, '0') from 4 for 1)::int * 5 +
                 substring(lpad(orm.record_num::text, 7, '0') from 3 for 1)::int * 6 +
                 substring(lpad(orm.record_num::text, 7, '0') from 2 for 1)::int * 7 +
                 substring(lpad(orm.record_num::text, 7, '0') from 1 for 1)::int * 8
                ) % 11
            )::text
        END AS order_record
    FROM sierra_view.record_metadata orm
)

SELECT
    bn.bib_record,

    string_agg(
        DISTINCT inum.item_record,
        ', '
        ORDER BY inum.item_record
    ) AS item_records,

    string_agg(
        DISTINCT cn.checkin_record,
        ', '
        ORDER BY cn.checkin_record
    ) AS checkin_records,

	string_agg(
        DISTINCT orn.order_record,
        ', '
        ORDER BY orn.order_record
    ) AS order_records    

FROM review_bibs rb

JOIN sierra_view.record_metadata brm
    ON rb.record_metadata_id = brm.id

JOIN sierra_view.bib_record b
    ON b.record_id = brm.id

JOIN bib_nums bn
    ON bn.record_metadata_id = brm.id

LEFT JOIN sierra_view.bib_record_item_record_link bil
    ON bil.bib_record_id = b.id

LEFT JOIN sierra_view.item_record i
    ON i.id = bil.item_record_id

LEFT JOIN sierra_view.record_metadata irm
    ON irm.id = i.record_id

LEFT JOIN item_nums inum
    ON inum.record_metadata_id = irm.id

LEFT JOIN sierra_view.bib_record_holding_record_link brhl
    ON brhl.bib_record_id = b.id

LEFT JOIN sierra_view.holding_record h
    ON h.id = brhl.holding_record_id

LEFT JOIN sierra_view.record_metadata hrm
    ON hrm.id = h.record_id

LEFT JOIN checkin_nums cn
    ON cn.record_metadata_id = hrm.id

LEFT JOIN sierra_view.bib_record_order_record_link brol
    ON brol.bib_record_id = b.id

LEFT JOIN sierra_view.order_record o
    ON o.id = brol.order_record_id

LEFT JOIN sierra_view.record_metadata orm
    ON orm.id = o.record_id

LEFT JOIN order_nums orn
    ON orn.record_metadata_id = orm.id	

GROUP BY
    bn.bib_record

ORDER BY
    bn.bib_record;
