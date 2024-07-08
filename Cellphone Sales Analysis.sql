--Cellphone Sales Analysis--
Use [Cellphone sales Analysis]
Select * From DIM_CUSTOMER
Select * From DIM_DATE
Select * From DIM_LOCATION
Select * From DIM_MANUFACTURER
Select * From DIM_MODEL
Select * From FACT_TRANSACTIONS



--1 List all the states in which we have customers who have bought cellphones from 2005 till today.
 
 Select Distinct(State) As [States]
 From DIM_LOCATION As X
 Inner Join FACT_TRANSACTIONS As Y
 On X.IDLocation=Y.IDLocation
 Where Year(Date)>=2005



-- What state in the US is buying the most 'Samsung' cell phones?
Select Top 1 (State) As [Top state] From DIM_LOCATION As A
Inner Join FACT_TRANSACTIONS As B on A.IDLocation=B.IDLocation
Inner Join  DIM_MODEL As C on B.IDModel=C.IDModel
Inner Join DIM_MANUFACTURER As D on C.IDManufacturer=D.IDManufacturer
Where Country='US' and Manufacturer_Name='Samsung'
Group by State
Order by COUNT(*) desc

	


     
--Show the number of transactions for each model per zip code per state.
Select Distinct A.IDModel As [Model],ZipCode,[State],
Country,COUNT(IDCustomer) As [Transactions]
From DIM_MODEL As A
Inner Join FACT_TRANSACTIONS As B on A.IDModel=B.IDModel
Inner Join DIM_LOCATION As C on B.IDLocation=C.IDLocation
Group By A.IDModel,ZipCode,[State],Country
Order by A.IDModel





--4 Show the cheapest cellphone (Output should contain the price)
Select Top 1 Manufacturer_Name As [Manufacturer],
Model_Name As [Cellphone Model],TotalPrice As [Price] 
From DIM_MODEL As A
Inner Join DIM_MANUFACTURER As B on A.IDManufacturer=B.IDManufacturer
Inner Join FACT_TRANSACTIONS As C on A.IDModel=C.IDModel
Order by Price






--. Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price.
Select * From 
(Select Top 5 Manufacturer_Name As [Manufacturer],Model_Name As [Model],
Avg(TotalPrice) As [Average Price],Sum(Quantity) As [Quantity Sold] 
From DIM_MODEL As A
Inner Join FACT_TRANSACTIONS As B on A.IDModel=B.IDModel
Inner Join DIM_MANUFACTURER As C on A.IDManufacturer=C.IDManufacturer
Group by Manufacturer_Name,Model_Name
Order by [Quantity Sold] Desc) As X
Order by [Average Price] Desc





--List the names of the customers and the average amount spent in 2009,where the average is higher than 500

Select Customer_Name As [Customers Name],
Avg(TotalPrice) As[Average Amount Spent]
From DIM_CUSTOMER As A
Left Join FACT_TRANSACTIONS As B on A.IDCustomer=B.IDCustomer
Left Join DIM_DATE As C on B.Date=C.DATE
Where YEAR=2009
Group By Customer_Name
Having Avg(TotalPrice)>500
Order By [Average Amount Spent] Desc



-- List if there is any model that was in the top 5 in terms of quantity simultaneously in 2008, 2009 and 2010
Select Model 
From 
(Select Top 5 Model_Name As [Model],
SUM(Quantity) As [Quantity] 
From 
DIM_MODEL As A
Inner Join FACT_TRANSACTIONS As B on A.IDModel=B.IDModel
Inner Join DIM_DATE As C on B.Date=C.DATE
Where YEAR=2008
Group By Model_Name
Order By [Quantity] Desc) As X

Intersect

Select Model 
From
(Select Top 5 Model_Name As [Model],
SUM(Quantity) As [Quantity] 
From 
DIM_MODEL As A
Inner Join FACT_TRANSACTIONS As B on A.IDModel=B.IDModel
Inner Join DIM_DATE As C on B.Date=C.DATE
Where YEAR=2009
Group By Model_Name
Order By [Quantity] Desc) As Y

Intersect

Select Model 
From 
(Select Top 5 Model_Name As [Model],
SUM(Quantity) As [Quantity] 
From
DIM_MODEL As A
Inner Join FACT_TRANSACTIONS As B on A.IDModel=B.IDModel
Inner Join DIM_DATE As C on B.Date=C.DATE
Where YEAR=2010
Group By Model_Name
Order By [Quantity] Desc) As Z




--Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.

Select Manufacturer As [Manufacturer with 2nd Top Sales],Year 
From
(Select Manufacturer_Name As [Manufacturer],
Sum(TotalPrice) As [Total Sales],Year,
Rank() Over(Order by Sum(TotalPrice) Desc) as Ranking
From DIM_MODEL As A
Inner Join FACT_TRANSACTIONS As B on A.IDModel=B.IDModel
Inner Join DIM_MANUFACTURER As C on A.IDManufacturer=C.IDManufacturer
Inner Join DIM_DATE As D on B.Date=D.DATE
Where Year=2009
Group by Manufacturer_Name,YEAR) As X
Where Ranking=2

Union All

Select Manufacturer As [Manufacturer with 2nd Top Sales],Year
From(Select Manufacturer_Name As [Manufacturer],
Sum(TotalPrice) As [Total Sales],Year,
Rank() Over(Order by Sum(TotalPrice) Desc) as Ranking
From DIM_MODEL As A
Inner Join FACT_TRANSACTIONS As B on A.IDModel=B.IDModel
Inner Join DIM_MANUFACTURER As C on A.IDManufacturer=C.IDManufacturer
Inner Join DIM_DATE As D on B.Date=D.DATE
Where Year=2010
Group by Manufacturer_Name,YEAR) As X
Where Ranking=2




-- Show the manufacturers that sold cellphones in 2010 but did not in 2009.
Select Distinct Manufacturer_Name As [Manufacturer] 
From DIM_MODEL As A
Inner Join FACT_TRANSACTIONS As B on A.IDModel=B.IDModel
Inner Join DIM_MANUFACTURER As C on A.IDManufacturer=C.IDManufacturer
Inner Join DIM_DATE As D on B.Date=D.DATE 
Where YEAR =2010 And Manufacturer_Name
Not In
(Select Distinct Manufacturer_Name As [Manufacturer] 
From DIM_MODEL As A
Inner Join FACT_TRANSACTIONS As B on A.IDModel=B.IDModel
Inner Join DIM_MANUFACTURER As C on A.IDManufacturer=C.IDManufacturer
Inner Join DIM_DATE As D on B.Date=D.DATE 
Where YEAR =2009)



-
--. Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.
Select TOP 100 Customers,[Average Quantity],[Average Spend],YEAR ,
(([Average Spend] - [Difference Average Spend Each year])*100/[Difference Average Spend Each year]) As [%Age of Change]
From(Select Customer_Name As [Customers] ,AVG(TotalPrice) As [Average Spend],
AVG(Quantity) As [Average Quantity],YEAR,
Lag(Avg(TotalPrice),1) over (partition by customer_name order by YEAR ) as [Difference Average Spend Each year]
From DIM_CUSTOMER As A
Inner Join FACT_TRANSACTIONS As B On A.IDCustomer=B.IDCustomer
Inner Join DIM_DATE As C On B.Date=C.DATE
Group by Customer_Name,YEAR) As X




