-- current version is for the 2026 fiscal year (starting Oct 1 2025), must update line 57 with new date for future years

SELECT 
    'o' || 
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
    END AS order_number,
    fm.code AS Fund,
    o.acq_type_code AS Acq_Type,
    o.form_code AS Form,
    o.order_status_code AS Status,
    bv.title AS Title,
    o.ocode1 AS code1,
    o.ocode3 AS code3,
    o.order_type_code AS Ord_Type,
    TO_CHAR(p.paid_date_gmt, 'MM-DD-YYYY') AS Paid_Date,
    TO_CHAR(p.invoice_date_gmt, 'MM-DD-YYYY') AS Invoice_Date,
    p.invoice_code AS Invoice_Num,
    TO_CHAR(p.paid_amount, 'FM999999999.00') AS Paid_Amount,
    p.voucher_num AS Voucher_Num,
    p.copies AS Copies,
    TO_CHAR(p.from_date_gmt, 'MM-DD-YYYY') AS Sub_From,
    TO_CHAR(p.to_date_gmt, 'MM-DD-YYYY') AS Sub_To,
    p.note AS Note
FROM sierra_view.order_record o
JOIN sierra_view.record_metadata rm
    ON rm.id = o.record_id
JOIN sierra_view.order_record_paid p
    ON p.order_record_id = o.id
JOIN sierra_view.order_record_cmf cmf
    ON cmf.order_record_id = o.id
JOIN sierra_view.bib_record_order_record_link bol
    ON bol.order_record_id = o.id
JOIN sierra_view.bib_view bv
    ON bv.id = bol.bib_record_id
LEFT JOIN sierra_view.fund_master fm
    ON fm.code_num = cmf.fund_code::int
WHERE rm.record_type_code = 'o'
  AND p.paid_date_gmt >= DATE '2025-10-01'
ORDER BY o.id, p.paid_date_gmt;
