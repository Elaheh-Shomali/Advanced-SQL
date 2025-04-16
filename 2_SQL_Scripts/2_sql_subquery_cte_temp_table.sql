/*

*******************************************************************************
*******************************************************************************

Breaking Down Complex Queries

*******************************************************************************
*******************************************************************************

Here we’ll explore three essential tools: subqueries, common table expressions (CTEs), 
and temporary tables. You’ll see how each helps you conquer complex data retrieval tasks 
by breaking them down into manageable steps, all while keeping your code clear and efficient.

------------------------------------------------------------------------------------------------
*/


/*******************************************************************************
- Subqueries:
Subqueries are powerful tools that allow you to embed one query within another. 
This lets you tackle complex data retrieval tasks by dividing them into smaller, 
easier-to-manage steps. Subqueries can be used within various clauses like SELECT, 
WHERE, or FROM, and are particularly useful when you need to filter or aggregate 
data based on the results of another query.
The syntax is straightforward: wrap your subquery in parentheses and position it 
strategically within the main query. It can appear in the SELECT, FROM, WHERE, or 
HAVING clauses, depending on your objective. 

Example:

SELECT
    ProductName,
    UnitPrice
FROM
	Products
WHERE
    ProductId IN (SELECT ProductId
		          FROM Order_Details
		          WHERE Discount > 0.2);

Here’s how it works:
1) The subquery is executed first. It compiles a list of ProductIDs corresponding 
to items sold with the specified discount.
2) Next, the main query runs, retrieving the name and price of each of these particular items.
3) There’s no limit to the number of nested queries you can use.
*******************************************************************************/


/*******************************************************************************
- Common Table Expressions:
A Common Table Expression (CTE) is a named temporary result set that you can reference 
within a query. Unlike subqueries, which are embedded within the main query, CTEs 
are defined separately and can be reused multiple times within a single statement.

Example:

WITH OrderItemQuantities AS (
    SELECT
        OrderID,
        SUM(od.Quantity) AS TotalQuantity
    FROM
        Order_Details
    GROUP BY OrderID
)
SELECT
    AVG(TotalQuantity) AS AvgQuantity
FROM
    OrderItemQuantities;
    
In this example, we created a CTE named OrderItemQuantities that calculates the 
total quantity of items in each individual order. Then the main query computes 
the average quantity across all orders.
*******************************************************************************/


/*******************************************************************************
- Temporary Tables:
Temporary tables are another tool in SQL that can be used to store and manipulate 
intermediate results. These tables are defined and populated with data within a 
session, and they can be queried and modified multiple times during that session. 
They are automatically deleted when the session ends, which makes them a good choice 
for storing temporary data.
The syntax for creating a temporary table is similar to that of creating a regular 
table, but with the addition of the TEMPORARY keyword.

Example:

CREATE TEMPORARY TABLE TempOrderTotals AS
SELECT
    OrderID,
    SUM(Quantity) AS TotalQuantity
FROM
    Order_Details
GROUP BY OrderID;

SELECT *
FROM TempOrderTotals;

Here’s how it works:
1) We create a temporary table that stores the total quantity of items in each order. 
2) We can then query this table as many times as we need within the same session.
*******************************************************************************/

USE chinook;

-- 1. What is the difference in minutes between the total length of 'Rock' tracks and 'Jazz' tracks?
SELECT 
    ((SELECT SUM(Milliseconds)
	FROM Track t
	JOIN Genre g ON t.GenreId = g.GenreId
	WHERE g.Name = 'Rock')
	- 
	(SELECT SUM(Milliseconds)
	FROM Track t
	JOIN Genre g ON t.GenreId = g.GenreId
	WHERE g.Name = 'Jazz'))
	/ 60000 AS LengthDifferenceMinutes;


-- 2. How many tracks have a length greater than the average track length?
SELECT 
    COUNT(*) AS TracksAboveAverageLength
FROM
    Track
WHERE
    Milliseconds > (SELECT AVG(Milliseconds)
					FROM Track);
            

-- 3. What is the percentage of tracks sold per genre?
SELECT 
    g.Name AS Genre,
    COUNT(il.TrackId) * 100 / (SELECT COUNT(TrackId) FROM InvoiceLine) AS PercentageSold
FROM
    InvoiceLine il
        JOIN
    Track t ON il.TrackId = t.TrackId
        JOIN
    Genre g ON t.GenreId = g.GenreId
GROUP BY g.GenreId, g.Name;


-- 4. Can you check that the column of percentages adds up to 100%?

WITH TableOfPercentages AS (
	SELECT 
		g.Name AS Genre,
		COUNT(il.TrackId) * 100.0 / (SELECT COUNT(TrackId) FROM InvoiceLine) AS PercentageSold
	FROM
		InvoiceLine il
			JOIN
		Track t ON il.TrackId = t.TrackId
			JOIN
		Genre g ON t.GenreId = g.GenreId
	GROUP BY g.Name
)
SELECT SUM(PercentageSold)
FROM TableOfPercentages;


-- 5. What is the difference between the highest number of tracks in a genre and the lowest?
SELECT MAX(NumTracks) - MIN(NumTracks) AS RangeOfTracksByGenre
FROM (
	  SELECT COUNT(*) AS NumTracks 
	  FROM Track
	  GROUP BY GenreId
) AS TrackCounts;


-- 6. What is the average value of Chinook customers (total spending)?
SELECT ROUND(AVG(TotalSpending), 2) AS AvgLifetimeSpend
FROM (
    SELECT c.CustomerId,
           SUM(i.Total) AS TotalSpending
    FROM Customer c
    JOIN Invoice i USING (CustomerId)
    GROUP BY c.CustomerId
) AS CustomerSpending;


-- 7. How many complete albums were sold? Not just tracks from an album, but the whole album bought on one invoice.

CREATE TEMPORARY TABLE TracksOnInvoice (
	SELECT
		il.invoiceid,
		t.albumid,
		COUNT(DISTINCT il.trackid) AS InvoiceTrackCount
	FROM
		invoiceline il
		LEFT JOIN
		track t USING (trackid)
	GROUP BY il.invoiceid, t.albumid
);

CREATE TEMPORARY TABLE TracksOnAlbum (
	SELECT 
		albumid,
        COUNT(DISTINCT trackid) AS AlbumTrackCount
	FROM
		track
	GROUP BY albumid
);

SELECT COUNT(AlbumTrackCount)
FROM TracksOnInvoice
	LEFT JOIN
		TracksOnAlbum USING (albumid)
WHERE InvoiceTrackCount = AlbumTrackCount;


-- 8. What is the maximum spent by a customer in each genre?

WITH CustomerSpendingPerGenre AS (
	SELECT
		g.Name AS Genre,
		c.CustomerId,
		SUM(il.UnitPrice * il.Quantity) AS Spend
	FROM
		Customer c
	JOIN
		Invoice i USING (CustomerId)
	JOIN
		InvoiceLine il USING (InvoiceId)
	JOIN
		Track t USING (TrackId)
	JOIN
		Genre g USING (GenreId)
	GROUP BY
		g.Name, c.CustomerId
)
SELECT
	Genre,
    MAX(Spend)
FROM CustomerSpendingPerGenre
GROUP BY Genre
ORDER BY MAX(Spend) DESC;
	

-- 9. What percentage of customers who made a purchase in 2022 returned to make additional purchases in subsequent years?

WITH PastCustomers AS (
	SELECT
		DISTINCT CustomerId
	FROM 
		invoice
	WHERE 
		YEAR(InvoiceDate) = 2022
)
SELECT 
	COUNT(DISTINCT CustomerId) * 100 / (SELECT COUNT(*) FROM PastCustomers) AS PercentageReturning
FROM 
	invoice
WHERE 
	YEAR(InvoiceDate) > 2022
	AND CustomerId IN (SELECT CustomerID FROM PastCustomers);
    

-- 10. Which genre is each employee most successful at selling? Most successful is greatest amount of tracks sold.

CREATE TEMPORARY TABLE AmountSoldPerEmployeePerGenre (
SELECT 
	e.employeeid,
    CONCAT(e.firstname, " ", e.lastname) AS EmployeeName,
    g.Name AS GenreName,
    SUM(il.quantity) AS QuantitySoldInGenre
FROM
	employee e
    JOIN customer c
		ON e.employeeid = c.supportrepid
	JOIN invoice i
		USING (customerid)
	JOIN invoiceline il
		USING (invoiceid)
	JOIN track t
		USING (trackid)
	JOIN genre g
		USING (genreid)
GROUP BY e.employeeid, g.genreid, g.Name
);

CREATE TEMPORARY TABLE MaxSoldPerEmployeePerGenre (
SELECT
	employeeid,
    EmployeeName,
    MAX(QuantitySoldInGenre) AS MaxSold
FROM
	AmountSoldPerEmployeePerGenre
GROUP BY employeeid, EmployeeName
);

SELECT 
	a.EmployeeName,
    a.GenreName
FROM
	MaxSoldPerEmployeePerGenre m
	JOIN
		AmountSoldPerEmployeePerGenre a USING (employeeid)
WHERE m.MaxSold = a.QuantitySoldInGenre;


-- 11. How many customers made a second purchase the month after their first purchase?

WITH FirstPurchaseTable AS (
	SELECT
		customerid,
		MIN(DATE(invoicedate)) AS DateOfFirstPurchase
	FROM invoice
    GROUP BY customerid
),
SecondPurchaseTable AS (
	SELECT
		customerid,
		MIN(DATE(invoicedate)) AS DateOfSecondPurchase
	FROM invoice
    JOIN FirstPurchaseTable USING (customerid)
    WHERE DATE(invoicedate) > DateOfFirstPurchase
    GROUP BY customerid
)
SELECT
	COUNT(*)
FROM (
	SELECT 
		DateOfFirstPurchase,
		DateOfSecondPurchase,
		TIMESTAMPDIFF(MONTH, DateOfFirstPurchase, DateOfSecondPurchase) AS MonthDifference
	FROM FirstPurchaseTable
		JOIN SecondPurchaseTable USING (customerid)
	HAVING MonthDifference = 1
) AS OnlyOneMonthDifference;