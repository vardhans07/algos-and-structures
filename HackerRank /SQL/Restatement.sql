/*
Julia conducted a  days of learning SQL contest. The start date of the contest was March 01, 2016 and the end date was March 15, 2016.

Write a query to print total number of unique hackers who made at least  submission each day (starting on the first day of the contest), and find the hacker_id and name of the hacker who made maximum number of submissions each day. If more than one such hacker has a maximum number of submissions, print the lowest hacker_id. The query should print this information for each day of the contest, sorted by the date.

Input Format

The following tables hold contest data:

Hackers: The hacker_id is the id of the hacker, and name is the name of the hacker.


Explanation

On March 01, 2016 hackers , , , and  made submissions. There are  unique hackers who made at least one submission each day. As each hacker made one submission,  is considered to be the hacker who made maximum number of submissions on this day. The name of the hacker is Angela.

On March 02, 2016 hackers , , and  made submissions. Now  and  were the only ones to submit every day, so there are  unique hackers who made at least one submission each day.  made  submissions, and name of the hacker is Michael.

On March 03, 2016 hackers , , and  made submissions. Now  and  were the only ones, so there are  unique hackers who made at least one submission each day. As each hacker made one submission so  is considered to be the hacker who made maximum number of submissions on this day. The name of the hacker is Angela.

On March 04, 2016 hackers , , , and  made submissions. Now  and  only submitted each day, so there are  unique hackers who made at least one submission each day. As each hacker made one submission so  is considered to be the hacker who made maximum number of submissions on this day. The name of the hacker is Angela.

On March 05, 2016 hackers , ,  and  made submissions. Now  only submitted each day, so there is only  unique hacker who made at least one submission each day.  made  submissions and name of the hacker is Frank.

On March 06, 2016 only  made submission, so there is only  unique hacker who made at least one submission each day.  made  submission and name of the hacker is Angela.
*/



-- Step 1: Count submissions per hacker per day
WITH daily_counts AS (
    SELECT submission_date,
           hacker_id,
           COUNT(*) AS submissions
    FROM Submissions
    GROUP BY submission_date, hacker_id
),

-- Step 2: For each day, rank hackers by submissions (highest first, tie → lowest hacker_id)
max_daily AS (
    SELECT submission_date,
           hacker_id,
           submissions,
           ROW_NUMBER() OVER (
               PARTITION BY submission_date
               ORDER BY submissions DESC, hacker_id ASC
           ) AS rn
    FROM daily_counts
),

-- Step 3: Collect distinct hacker/day pairs (who submitted at least once that day)
active_hackers AS (
    SELECT s.hacker_id, s.submission_date
    FROM Submissions s
    GROUP BY s.hacker_id, s.submission_date
),

-- Step 4: Count hackers who submitted every day up to that date (continuous participation)
continuous AS (
    SELECT submission_date,
           COUNT(DISTINCT hacker_id) AS total_active
    FROM active_hackers ah
    WHERE NOT EXISTS (
        SELECT 1
        FROM (
            SELECT DISTINCT submission_date
            FROM Submissions
        ) d
        WHERE d.submission_date <= ah.submission_date
          AND NOT EXISTS (
              SELECT 1
              FROM Submissions s
              WHERE s.hacker_id = ah.hacker_id
                AND s.submission_date = d.submission_date
          )
    )
    GROUP BY submission_date
)

-- Step 5: Final output → join continuous counts with max_daily hacker info
SELECT c.submission_date,
       c.total_active,
       h.hacker_id,
       h.name
FROM continuous c
JOIN max_daily m ON c.submission_date = m.submission_date AND m.rn = 1
JOIN Hackers h ON m.hacker_id = h.hacker_id
ORDER BY c.submission_date;
