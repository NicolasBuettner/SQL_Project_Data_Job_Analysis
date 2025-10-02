-- Problem 1

/*
From the job_postings_fact table, categorize the salaries from job postings that are data analyst jobs, and that have yearly salary information. Put salary into 3 different categories:

1. If the salary_year_avg is greater than or equal to $100,000, then return ‘high salary’.
2. If the salary_year_avg is greater than or equal to $60,000 but less than $100,000, then return ‘Standard salary.’
3. If the salary_year_avg is below $60,000 return ‘Low salary’.

Also, order from the highest to the lowest salaries.
*/

SELECT 
    job_id,
    job_title,
    salary_year_avg,
    CASE 
        WHEN salary_year_avg >= 100000 THEN 'high salary'
        WHEN salary_year_avg >= 60000 THEN 'standard salary'
        ELSE 'low salary'
    END AS salary_category
FROM 
    job_postings_fact
WHERE 
    salary_year_avg IS NOT NULL
    AND job_title_short = 'Data Analyst'
    
ORDER BY salary_year_avg DESC;


-- Probem 2

/*
Count the number of unique companies that offer work from home (WFH) versus those requiring work to be on-site. 
Use the job_postings_fact table to count and compare the distinct companies based on their WFH policy (job_work_from_home).
*/

-- Luke's solution
SELECT 
    COUNT(DISTINCT CASE WHEN job_work_from_home = TRUE THEN company_id END) AS wfh_companies,
    COUNT(DISTINCT CASE WHEN job_work_from_home = FALSE THEN company_id END) AS non_wfh_companies
FROM job_postings_fact;

-- My approach
SELECT
    COUNT (DISTINCT company_id) AS company_count,
    CASE 
        WHEN job_work_from_home = TRUE THEN TRUE
        WHEN job_work_from_home = FALSE THEN FALSE
    END AS WFH
FROM
    job_postings_fact
GROUP BY
    WFH;



-- Problem 3

/*
Write a SQL query using the job_postings_fact table that returns the following columns:
- job_id
- salary_year_avg
- experience_level (derived using a CASE WHEN)
- remote_option (derived using a CASE WHEN)
Only include rows where salary_year_avg is not null.

Instructions:
1. Experience Level
Create a new column called experience_level based on keywords in the job_title column:
- Contains "Senior" → 'Senior'
- Contains "Manager" or "Lead" → 'Lead/Manager'
- Contains "Junior" or "Entry" → 'Junior/Entry'
- Otherwise → 'Not Specified'
Use ILIKE instead of LIKE to perform case-insensitive matching (PostgreSQL-specific).

2. Remote Option
Create a new column called remote_option:
- If job_work_from_home is true → 'Yes'
- Otherwise → 'No'

3. Filter and Order
- Filter out rows where salary_year_avg is NULL
- Order the results by job_id
*/

SELECT
    job_id,
    salary_year_avg,
        CASE
        WHEN job_title ILIKE '%senior%' THEN 'Senior'
        WHEN (job_title ILIKE '%manager%' OR job_title ILIKE '%lead%') THEN 'Lead/Manager'
        WHEN (job_title ILIKE '%junior%' OR job_title ILIKE '%entry%') THEN 'Junior/Entry'
        ELSE 'Not Specified'
    END AS experience_level,
    CASE
        WHEN job_work_from_home = TRUE THEN 'Yes'
        ELSE 'No'
    END AS remote_option
FROM job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
ORDER BY job_id;