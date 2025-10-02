-- Problem 1

/*
Find the average salary both yearly (salary_year_avg) and hourly (salary_hour_avg) for job postings
using the job_postings_fact table that were posted after June 1, 2023. Group the results by job schedule type. 
Order by the job_schedule_type in ascending order.
*/

SELECT
    job_schedule_type,
    AVG(salary_year_avg) AS avg_yearly_salary,
    AVG(salary_hour_avg) AS avg_hourly_salary
FROM
    job_postings_fact
WHERE
    job_posted_date::DATE > '2023-06-01'
GROUP BY
    job_schedule_type
ORDER BY
    job_schedule_type;


-- Problem 2

/*
Count the number of job postings for each month, adjusting the job_posted_date to be in 'America/New_York' time zone 
before extracting the month. Assume the job_posted_date is stored in UTC. Group by and order by the month.
*/

SELECT
    EXTRACT(MONTH FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') AS month,
    COUNT(*) AS postings_count
FROM
    job_postings_fact
GROUP BY
    month
ORDER BY
    month;


-- Problem 3

/*
Find companies (include company name) that have posted jobs offering health insurance, 
where these postings were made in the second quarter of 2023. 
Use date extraction to filter by quarter. 
And order by the job postings count from highest to lowest.
*/

SELECT
    company_dim.name AS company_name,
    COUNT(job_postings_fact.job_id) AS job_postings_count
FROM
    job_postings_fact
	INNER JOIN
    company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_postings_fact.job_health_insurance = TRUE
    AND EXTRACT(QUARTER FROM job_postings_fact.job_posted_date) = 2 
GROUP BY
    company_dim.name 
HAVING
    COUNT(job_postings_fact.job_id) > 0
ORDER BY
	job_postings_count DESC; 




