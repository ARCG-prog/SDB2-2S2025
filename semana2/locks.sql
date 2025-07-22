SELECT
    a.pid AS blocked_pid,
    a.query AS blocked_query,
    b.pid AS blocking_pid,
    b.query AS blocking_query,
    now() - a.query_start AS wait_duration
FROM pg_locks l1
JOIN pg_stat_activity a ON l1.pid = a.pid
JOIN pg_locks l2 ON (
    l1.locktype = l2.locktype
    AND l1.database IS NOT DISTINCT FROM l2.database
    AND l1.relation IS NOT DISTINCT FROM l2.relation
    AND l1.page IS NOT DISTINCT FROM l2.page
    AND l1.tuple IS NOT DISTINCT FROM l2.tuple
)
JOIN pg_stat_activity b ON l2.pid = b.pid
WHERE NOT l1.granted AND l2.granted;
