/* SAS Studio Action: Fourth Monday Bug Report
   Creates a table with open bug tickets for Global Engineering
   across the fourth Monday of each month for 2026
*/

CREATE TABLE WORK.fourth_monday_of_month AS

WITH snapshot_dates AS (
    -- Define the fourth Monday of each month for 2026
    SELECT CAST(date_val AS DATE) AS snapshot_dt
    FROM (VALUES 
        ('2025-12-31'), 
        ('2026-01-26'), ('2026-02-23'), ('2026-03-23'),
        ('2026-04-27'), ('2026-05-25'), ('2026-06-22'),
        ('2026-07-27'), ('2026-08-24'), ('2026-09-28'),
        ('2026-10-26'), ('2026-11-23'), ('2026-12-28')
    ) AS dates(date_val)
)
SELECT 
    s.snapshot_dt,
    COUNT(d.project_key_id) AS open_ticket_count
FROM snapshot_dates s
LEFT JOIN report_mart.jira_radar_detail_dev d 
    ON CAST(d.create_dt AS DATE) <= s.snapshot_dt
    -- LOGIC: Ticket is open OR was resolved after the snapshot date OR has no close date
    AND (
         d.open_flg = 'Y' 
         OR CAST(d.close_dt AS DATE) > s.snapshot_dt
         OR d.close_dt IS NULL -- Handles missing close dates
    )
WHERE 
    d.rd_organization_nm = 'Global Engineering'
    AND d.issue_type_nm = 'BUG'
    
    -- Exclude specific Project Keys
    AND d.project_key_id NOT IN (
        'ALCTRIAGE',
        'ALCAASTRIAGE',
        'DMTRIAGE',
        'EDMTRIAGE',
        'FFCTRIAGE',
        'FNDTRG',
        'G11NTRIAGE',
        'GOVTRIAGE',
        'IIOTTRIAGE',
        'RLOBTRIAGE',
        'RQSTRIAGE',
        'SAS9TRIAGE',
        'VATRIAGE',
        'VITRIAGE',
        'VIYA35TRIAGE'
    )
    -- Exclude specific Resolutions
    AND (
        d.jira_resolution_nm NOT IN (
            'Accepted Risk', 'Cancelled', 'Cannot Reproduce', 'Declined', 'Duplicate',
            'Exception', 'Feature Request', 'Future Evaluation', 'Incomplete',
            'No longer required', 'Not a Bug', 'Not Applicable', 'Provisional',
            'Redirect', 'Rejected', 'Reporter Timeout', 'Requires Redo', 'Restricted',
            'Superseded', 'Won''t Do', 'Won''t Fix', 'Work Required'
        )
        OR d.jira_resolution_nm IS NULL 
        OR d.jira_resolution_nm = ''
    )
GROUP BY s.snapshot_dt
ORDER BY s.snapshot_dt;

/* Output table: WORK.fourth_monday_of_month
   Contains: snapshot_dt and open_ticket_count for each fourth Monday
*/
