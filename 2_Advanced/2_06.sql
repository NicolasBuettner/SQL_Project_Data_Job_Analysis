-- Problem 1

/*
Create a unified query that categorizes job postings into two groups: 
those with salary information (salary_year_avg or salary_hour_avg is not null) 
and those without it. 
Each job posting should be listed with its job_id, job_title, 
and an indicator of whether salary information is provided.
*/

-- Luke's solution (with UNION ALL)

-- Select job postings with salary information
(
SELECT 
    job_id, 
    job_title, 
    'With Salary Info' AS salary_info  -- Custom field indicating salary info presence
FROM 
    job_postings_fact
WHERE 
    salary_year_avg IS NOT NULL OR salary_hour_avg IS NOT NULL  
)
UNION ALL
 -- Select job postings without salary information
(
SELECT 
    job_id, 
    job_title, 
    'Without Salary Info' AS salary_info  -- Custom field indicating absence of salary info
FROM 
    job_postings_fact
WHERE 
    salary_year_avg IS NULL AND salary_hour_avg IS NULL 
)
ORDER BY 
    salary_info DESC, 
    job_id; 

-- My (shorter) approach (no UNION needed)

SELECT
    job_id,
    job_title,
    CASE 
        WHEN salary_year_avg IS NOT NULL OR salary_hour_avg IS NOT NULL THEN 'With Salary Information'
        ELSE 'Without Salary Information'
    END AS salary_information
FROM
    job_postings_fact
ORDER BY 
    salary_information DESC, 
    job_id; 



-- Problem 2

/*
Retrieve the job id, job title short, job location, job via, skill and skill type 
for each job posting from the first quarter (January to March). 
Using a subquery to combine job postings from the first quarter.
Only include postings with an average yearly salary greater than $70,000.
*/

SELECT
    quarter1_job_postings.job_id,
    quarter1_job_postings.job_title_short,
    quarter1_job_postings.job_location,
    quarter1_job_postings.job_via,
    skills_dim.skills,
    skills_dim.type
FROM
    (
    SELECT *
    FROM january_jobs
    UNION ALL
    SELECT *
    FROM february_jobs
    UNION ALL
    SELECT *
    FROM march_jobs
    ) AS quarter1_job_postings 
LEFT JOIN
    skills_job_dim ON quarter1_job_postings.job_id = skills_job_dim.job_id
LEFT JOIN
    skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE 
    salary_year_avg > 70000
ORDER BY
    quarter1_job_postings.job_id;



-- Problem 3

/*
Analyze the monthly demand for skills by counting the number of job postings 
for each skill in the first quarter (January to March), 
utilizing data from separate tables for each month. 
Ensure to include skills from all job postings across these months.
*/

-- CTE for combining job postings from January, February, and March
WITH combined_job_postings AS (
    SELECT job_id, job_posted_date
    FROM january_jobs
    UNION ALL
    SELECT job_id, job_posted_date
    FROM february_jobs
    UNION ALL
    SELECT job_id, job_posted_date
    FROM march_jobs
),

-- CTE for calculating monthly skill demand based on the combined postings
monthly_skill_demand AS (
    SELECT
        skills_dim.skills,  
        EXTRACT(YEAR FROM combined_job_postings.job_posted_date) AS year_var,  
        EXTRACT(MONTH FROM combined_job_postings.job_posted_date) AS month_var,  
        COUNT(combined_job_postings.job_id) AS postings_count 
    FROM
        combined_job_postings
    INNER JOIN skills_job_dim ON combined_job_postings.job_id = skills_job_dim.job_id  
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id  
    GROUP BY
        skills_dim.skills, 
        year_var, 
        month_var
)

-- Main query to display the demand for each skill during the first quarter
SELECT
    skills,  
    year_var,  
    month_var,  
    postings_count 
FROM
    monthly_skill_demand
ORDER BY
    skills, 
    year_var,
    month_var;  






