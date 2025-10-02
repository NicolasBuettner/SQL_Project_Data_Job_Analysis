-- Problem 1

/*
Identify the top 5 skills that are most frequently mentioned in job postings. 
Use a subquery to find the skill IDs with the highest counts in the skills_job_dim table 
and then join this result with the skills_dim table to get the skill names.

Hint:
Focus on creating a subquery that identifies and ranks (ORDER BY in descending order) 
the top 5 skill IDs by their frequency (COUNT) of mention in job postings.
Then join this subquery with the skills table (skills_dim) to match IDs to skill names.
*/

SELECT 
    skills_dim.skills
FROM 
    skills_dim
INNER JOIN (
    SELECT
        skill_id,
        COUNT(skill_id) as skill_count
    FROM 
        skills_job_dim
    GROUP BY
        skill_id
    ORDER BY
        skill_count DESC
    LIMIT 5
) AS top_skills
    ON skills_dim.skill_id = top_skills.skill_id
ORDER BY
top_skills.skill_count DESC;



-- Problem 2

/*
Determine the size category ('Small', 'Medium', or 'Large') for each company 
by first identifying the number of job postings they have. 
Use a subquery to calculate the total job postings per company. 
A company is considered 'Small' if it has less than 10 job postings, 
'Medium' if the number of job postings is between 10 and 50, and 'Large' if it has more than 50 job postings. 
Implement a subquery to aggregate job counts per company before classifying them based on size.

HINTS:
- Aggregate job counts per company in the subquery. This involves grouping by company and counting job postings.
- Use this subquery in the FROM clause of your main query.
- In the main query, categorize companies based on the aggregated job counts from the subquery with a CASE statement.
- The subquery prepares data (counts jobs per company), and the outer query classifies companies based on these counts.
*/

SELECT
   company_id,
   name,
   -- Categorize companies
   CASE
       WHEN job_count < 10 THEN 'Small'
       WHEN job_count BETWEEN 10 AND 50 THEN 'Medium'
       ELSE 'Large'
   END AS company_size
FROM (
   -- Subquery to calculate number of job postings per company 
   SELECT
       company_dim.company_id,
       company_dim.name,
       COUNT(job_postings_fact.job_id) AS job_count
   FROM company_dim
   INNER JOIN job_postings_fact 
       ON company_dim.company_id = job_postings_fact.company_id
   GROUP BY
       company_dim.company_id,
       company_dim.name
) AS company_job_count;



-- Problem 2

/*
Your goal is to find the names of companies that have an average salary 
greater than the overall average salary across all job postings.
You'll need to use two tables: company_dim (for company names) and job_postings_fact (for salary data). 
The solution requires using subqueries.

Hint:
Think of it as needing three pieces of information:
1. The average salary for each company.
2. The single overall average salary across all jobs.
3. The names of the companies.
You'll build this query from the inside out.
Detailed hints in course online
*/

SELECT 
    company_dim.name
FROM 
    company_dim
INNER JOIN (
    -- Subquery to calculate average salary per company
    SELECT 
        company_id, 
        AVG(salary_year_avg) AS avg_salary
    FROM job_postings_fact
    GROUP BY company_id
    ) AS company_salaries ON company_dim.company_id = company_salaries.company_id
-- Filter for companies with an average salary greater than the overall average
WHERE company_salaries.avg_salary > (
    -- Subquery to calculate the overall average salary
    SELECT AVG(salary_year_avg)
    FROM job_postings_fact
);

