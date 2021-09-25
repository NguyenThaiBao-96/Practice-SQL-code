-- The goal is to calculate the AVERAGE yearly Salary of each EMPLOYEE GROUP, in EUR
-- We need to prepare 2 CTEs as the original tables are not ready to be analyzed.
USE MantuEmployees
GO


-- For the Salary Table, first we need to exchange the salary from local currency to EUR. Then, as some employees have 2 salary packages, we need to sum them up.
WITH slr AS
(
	SELECT EmployeeId,  sum(Yearly_Salary_Amount_in_EUR) as Yearly_Salary_Amount_in_EUR
	FROM
		(
			SELECT
				s.EmployeeId,
				--s.Employee,
				s.Yearly_Salary_Amount,
				s.Yearly_Salary_Currency,
				c.Average,
				(s.Yearly_Salary_Amount / c.Average) as Yearly_Salary_Amount_in_EUR
			FROM Salary s
			INNER JOIN Currency c
				ON s.Yearly_Salary_Currency = c.Currency
		) as conso_slr
	GROUP BY EmployeeId
),

-- For the Employee Table, we need to categorize all employees based on their Employee Type and Governance.\
	emp AS
(
	SELECT 
		EmployeeId,
		EmployeeType,
		Governance,
		(CASE 
			WHEN EmployeeType = 'Consultant' THEN 'Consultants'
			WHEN EmployeeType = 'Staff'	
				AND Governance IN ('Administrative & Finance', 'Information Technology', 'Marketing & Conversation', 'Human Resources', 'General Secretary', 'Recruitment', 'Corporate Management')
				THEN 'Corporate Staff'
			ELSE 'Business Staff' END
		) as Employee_category
	FROM
		Employees
)

-- After that, we join 2 CTEs then group them by Employee Category.
Select 
	emp.Employee_category,
	AVG (slr.Yearly_Salary_Amount_in_EUR) as Avg_Yearly_Salary_in_EUR
FROM emp
JOIN slr
	ON emp.EmployeeId = slr.EmployeeId
Group by emp.Employee_category
	
