-- Problem 1

/*
Identify companies with the most diverse (unique) job titles. 
Use a CTE to count the number of unique job titles per company, then select companies with the highest diversity in job titles.
*/

-- Define a CTE named title_diversity to calculate unique job titles per company
WITH title_diversity AS (
    SELECT
        company_id,
        COUNT(DISTINCT job_title) AS unique_titles  
    FROM 
        job_postings_fact
    GROUP BY 
        company_id  
)
-- Get company name and count of how many unique titles each company has
SELECT
    company_dim.name,  
    title_diversity.unique_titles  
FROM 
    title_diversity
INNER JOIN 
    company_dim ON title_diversity.company_id = company_dim.company_id  
ORDER BY 
	unique_titles DESC  
LIMIT 10;  



-- Problem 2

/*
Explore job postings by listing job id, job titles, company names, 
and their average salary rates, while categorizing these salaries 
relative to the average in their respective countries. 
Include the month of the job posted date. Use CTEs, conditional logic, 
and date functions, to compare individual salaries with national averages.
*/

-- gets average job salary for each country
WITH avg_salaries AS (
    SELECT 
        job_country, 
        AVG(salary_year_avg) AS avg_salary
    FROM job_postings_fact
    GROUP BY job_country
)

SELECT
    -- Gets basic job info
    job_postings.job_id,
    job_postings.job_title,
    companies.name AS company_name,
    job_postings.salary_year_avg AS salary_rate,
    -- categorizes the salary as above or below average the average salary for the country
    CASE
        WHEN job_postings.salary_year_avg IS NULL OR avg_salaries.avg_salary IS NULL THEN 'Unknown'
        WHEN job_postings.salary_year_avg > avg_salaries.avg_salary THEN 'Above Average'
        WHEN job_postings.salary_year_avg < avg_salaries.avg_salary THEN 'Below Average'
        ELSE 'Average'
    END AS salary_category,
    -- gets the month and year of the job posting date
    EXTRACT(MONTH FROM job_postings.job_posted_date) AS posting_month
FROM
    job_postings_fact as job_postings
INNER JOIN
    company_dim as companies ON job_postings.company_id = companies.company_id
INNER JOIN
    avg_salaries ON job_postings.job_country = avg_salaries.job_country
ORDER BY
    -- Sorts it by the most recent job postings
    posting_month desc;



-- Problem 3

/*
Your goal is to calculate two metrics for each company:
1. The number of unique skills required for their job postings.
2. The highest average annual salary among job postings that require at least one skill.

Your final query should return the company name, the count of unique skills, 
and the highest salary. For companies with no skill-related job postings, 
the skill count should be 0 and the salary should be null.
*/


-- Counts the distinct skills required for each company's job posting
WITH required_skills AS (
    SELECT
        company_dim.company_id,
        COUNT(DISTINCT skills_job_dim.skill_id) AS unique_skills
    FROM
        company_dim 
    LEFT JOIN 
        job_postings_fact ON company_dim.company_id = job_postings_fact.company_id
    LEFT JOIN 
        skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    GROUP BY
        company_dim.company_id
),

-- Gets the highest average yearly salary from the jobs that require at least one skills 
max_salary AS (
    SELECT
        job_postings_fact.company_id,
        MAX(job_postings_fact.salary_year_avg) AS highest_salary
    FROM
        job_postings_fact
    WHERE
        job_postings_fact.job_id IN (SELECT job_id FROM skills_job_dim)
    GROUP BY
        job_postings_fact.company_id
)

-- Joins 2 CTEs with table to get the query
SELECT
    company_dim.name,
    required_skills.unique_skills,
    max_salary.highest_salary
FROM
    company_dim
LEFT JOIN
    required_skills ON company_dim.company_id = required_skills.company_id
LEFT JOIN
    max_salary ON company_dim.company_id = max_salary.company_id
ORDER BY
    company_dim.name;
