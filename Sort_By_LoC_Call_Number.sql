WITH review_items AS (
    SELECT bs.record_metadata_id
    FROM sierra_view.bool_set bs
    JOIN sierra_view.bool_info bi
        ON bs.bool_info_id = bi.id
    WHERE bi.id = :review_id
),
cleaned_items AS (
    SELECT
        ir.id AS item_id,
        rm.record_num AS item_record_num,
        brm.record_num AS bib_record_num,
        irp.barcode,
        irp.call_number,
        LTRIM(regexp_replace(irp.call_number::text, '\|a', '', 'g')) AS cn_clean,
        ir.location_code AS item_location,
        ir.icode2 AS item_code2,
        ir.inventory_gmt,
        rm.record_last_updated_gmt,
        bl.location_code AS bib_location,
        br.bcode3 AS bib_code3,

        -- MARC fields coming from the *bib* record_metadata (brm.id)
        vf_bib.marc001,
        vf_bib.marc082,
        vf_bib.marc099,
        vf_bib.marc245,
        vf_bib.marc740,

        -- Fields coming from the *item* record_metadata (rm.id)
        vf_item.marc050,
        vf_item.volumetext,
        vf_item.source_note,
        vf_item.internal_note

    FROM review_items ri
    JOIN sierra_view.item_record ir
        ON ir.record_id = ri.record_metadata_id
    JOIN sierra_view.item_record_property irp
        ON irp.item_record_id = ir.id
    JOIN sierra_view.record_metadata rm
        ON rm.id = ir.record_id
    JOIN sierra_view.bib_record_item_record_link brl
        ON brl.item_record_id = ir.id
    JOIN sierra_view.bib_record br
        ON br.id = brl.bib_record_id
    JOIN sierra_view.record_metadata brm
        ON brm.id = br.id
    LEFT JOIN sierra_view.bib_record_location bl
        ON bl.bib_record_id = br.id

    /* varfields that belong to the BIB record (brm.id) */
    LEFT JOIN (
        SELECT record_id,
               MAX(CASE WHEN marc_tag = '001' THEN field_content END) AS marc001,
               MAX(CASE WHEN marc_tag = '082' THEN field_content END) AS marc082,
               MAX(CASE WHEN marc_tag = '099' THEN field_content END) AS marc099,
               MAX(CASE WHEN marc_tag = '245' THEN field_content END) AS marc245,
               MAX(CASE WHEN marc_tag = '740' THEN field_content END) AS marc740
        FROM sierra_view.varfield
        WHERE marc_tag IN ('001','082','099','245','740')
        GROUP BY record_id
    ) vf_bib ON vf_bib.record_id = brm.id

    /* varfields that belong to the ITEM's record_metadata (rm.id) */
    LEFT JOIN (
        SELECT record_id,
               MAX(CASE WHEN marc_tag = '050' THEN field_content END) AS marc050,
               MAX(CASE WHEN varfield_type_code = 'v' THEN field_content END) AS volumetext,
               MAX(CASE WHEN varfield_type_code = 's' THEN field_content END) AS source_note,
               MAX(CASE WHEN varfield_type_code = 'x' THEN field_content END) AS internal_note
        FROM sierra_view.varfield
        WHERE marc_tag = '050' OR varfield_type_code IN ('v','s','x')
        GROUP BY record_id
    ) vf_item ON vf_item.record_id = rm.id
),
parsed_cn AS (
    SELECT
        ci.*,

        -- original classification extraction (letters + number, or letters only)
        classpair.class_letters_raw,
        classpair.class_number_raw,
        classpair.class_main,
        classonly.class_letters_only,

        -- normalized ordering key: prefer letters+number letters, otherwise letters-only,
        -- and make uppercase so case differences don't change order
        UPPER(TRIM(COALESCE(classpair.class_letters_raw, classonly.class_letters_only, ''))) AS ord_class,

        substring(ci.cn_clean FROM char_length(COALESCE(classpair.class_main, classonly.class_letters_only, '')) + 1) AS remainder,

        CASE
            WHEN classpair.class_number_raw ~ '^\d+(\.\d+)?$'
                THEN split_part(classpair.class_number_raw, '.', 1)::int
            ELSE 0
        END AS cn_first_num,

        LPAD(COALESCE(NULLIF(split_part(classpair.class_number_raw, '.', 2), ''), '0'), 10, '0') AS cn_decimal,

        cutters1.cutter1_letter,
        cutters1.cutter1_number,
        cutters2.cutter2_letter,
        cutters2.cutter2_number,

        LPAD(COALESCE(NULLIF(regexp_replace(ci.cn_clean, '.*v\.(\d+).*', '\1', 'g'), ''), '0'), 5, '0') AS volume_number,
        LPAD(COALESCE(NULLIF(regexp_replace(ci.cn_clean, '.* (\d{4})$', '\1', 'g'), ''), '0'), 4, '0') AS cn_year

    FROM cleaned_items ci

    LEFT JOIN LATERAL (
        SELECT
            m[1] AS class_letters_raw,
            m[2] AS class_number_raw,
            (m[1] || m[2]) AS class_main
        FROM regexp_matches(
            ci.cn_clean,
            '^([A-Za-z]+(?:[[:space:]]+[A-Za-z]+)*)[[:space:].]*([0-9]+(?:\.[0-9]+)?)'
        ) AS m
        LIMIT 1
    ) classpair ON true

    LEFT JOIN LATERAL (
        SELECT m[1] AS class_letters_only
        FROM regexp_matches(ci.cn_clean, '^([A-Za-z]+(?:[[:space:]]+[A-Za-z]+)*)') AS m
        LIMIT 1
    ) classonly ON classpair.class_letters_raw IS NULL

    LEFT JOIN LATERAL (
        SELECT
            UPPER(m[1]) AS cutter1_letter,
            (CAST(m[2] AS numeric) / POWER(10, LENGTH(m[2]))) AS cutter1_number
        FROM regexp_matches(
            substring(ci.cn_clean FROM char_length(COALESCE(classpair.class_main, classonly.class_letters_only, '')) + 1),
            '(?:[.]?[[:space:]]*)([A-Za-z])([0-9]+)',
            'g'
        ) AS m
        LIMIT 1
    ) cutters1 ON true

    LEFT JOIN LATERAL (
        SELECT
            UPPER(m[1]) AS cutter2_letter,
            (CAST(m[2] AS numeric) / POWER(10, LENGTH(m[2]))) AS cutter2_number
        FROM regexp_matches(
            substring(ci.cn_clean FROM char_length(COALESCE(classpair.class_main, classonly.class_letters_only, '')) + 1),
            '(?:[.]?[[:space:]]*)([A-Za-z])([0-9]+)',
            'g'
        ) AS m
        OFFSET 1 LIMIT 1
    ) cutters2 ON true
),
aggregated AS (
    SELECT
        'i' || ci.item_record_num::text ||
          (CASE WHEN (rm_cd.s % 11) = 10 THEN 'x' ELSE (rm_cd.s % 11)::text END) AS item_record,
        string_agg(DISTINCT 'b' || ci.bib_record_num::text ||
          (CASE WHEN (brm_cd.s % 11) = 10 THEN 'x' ELSE (brm_cd.s % 11)::text END), ', ') AS bib_records,

        -- keep original-style outputs but aggregated using MAX() where appropriate
        MAX(ci.marc001) AS marc001,
        string_agg(DISTINCT ci.bib_location, ', ') AS bib_locations,
        MAX(ci.item_location) AS item_location,
        MAX(ci.item_code2) AS item_code2,
        MAX(ci.bib_code3) AS bib_code3,
        MAX(ci.inventory_gmt) AS inventory_gmt,
        MAX(ci.record_last_updated_gmt) AS record_last_updated_gmt,
        MAX(ci.barcode) AS barcode,
        MAX(ci.cn_clean) AS cn_clean,
        MAX(ci.marc050) AS marc050,
        MAX(ci.marc082) AS marc082,
        MAX(ci.marc099) AS marc099,
        MAX(ci.volumetext) AS volumetext,
        MAX(ci.marc245) AS marc245,
        MAX(ci.source_note) AS source_note,
        MAX(ci.marc740) AS marc740,
        MAX(ci.internal_note) AS internal_note,

        -- ordering fields (aggregated)
        MAX(ci.ord_class) AS ord_class,
        MAX(ci.class_letters_raw) AS class_letters_raw,
        MAX(ci.class_letters_only) AS class_letters_only,
        MAX(ci.cn_first_num) AS cn_first_num,
        MAX(ci.cn_decimal) AS cn_decimal,
        MAX(ci.cutter1_letter) AS cutter1_letter,
        MAX(ci.cutter1_number) AS cutter1_number,
        MAX(ci.cutter2_letter) AS cutter2_letter,
        MAX(ci.cutter2_number) AS cutter2_number,
        MAX(ci.volume_number) AS volume_number,
        MAX(ci.cn_year) AS cn_year

    FROM parsed_cn ci
    LEFT JOIN LATERAL (
        SELECT SUM(
            (substring(LPAD(regexp_replace(ci.bib_record_num::text,'[^0-9]','','g'),7,'0') from gs for 1)::int
             * (array[8,7,6,5,4,3,2])[gs]
            )
        ) AS s
        FROM generate_series(1,7) gs
    ) brm_cd ON true
    LEFT JOIN LATERAL (
        SELECT SUM(
            (substring(LPAD(regexp_replace(ci.item_record_num::text,'[^0-9]','','g'),7,'0') from gs for 1)::int
             * (array[8,7,6,5,4,3,2])[gs]
            )
        ) AS s
        FROM generate_series(1,7) gs
    ) rm_cd ON true

    GROUP BY ci.item_id, ci.item_record_num, brm_cd.s, rm_cd.s
)
SELECT
    item_record AS "Item Record",
    bib_records AS "Bib Record",
    marc001 AS "MARC Tag 001",
    bib_locations AS "Bib Locations",
    item_location AS "Item Location",
    item_code2 AS "Item Code 2",
    bib_code3 AS "Bib Code 3",
    TO_CHAR(inventory_gmt, 'MM-DD-YYYY') AS "Inventory Date",
    TO_CHAR(record_last_updated_gmt, 'MM-DD-YYYY') AS "Updated Date",
    barcode AS "Barcode",
    cn_clean AS "Call Number",
    marc050 AS "MARC Tag 050",
    marc082 AS "MARC Tag 082",
    marc099 AS "MARC Tag 099",
    volumetext AS "Volume",
    marc245 AS "MARC Tag 245",
    source_note AS "Source",
    marc740 AS "MARC Tag 740",
    internal_note AS "Internal Note"

FROM aggregated
ORDER BY
    ord_class,
    cn_first_num,
    cn_decimal,
    cutter1_letter,
    cutter1_number,
    cutter2_letter,
    cutter2_number,
    volume_number,
    cn_year,
    cn_clean;
