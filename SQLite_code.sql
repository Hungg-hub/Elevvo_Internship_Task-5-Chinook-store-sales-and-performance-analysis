
--Top 10 Top 10 Selling Products / Tracks
SELECT 
    t.TrackId,
    t.Name AS track_name,
    a.Title AS album_title,
    SUM(il.Quantity) AS units_sold,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS total_revenue
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Album a ON t.AlbumId = a.AlbumId
GROUP BY t.TrackId, t.Name, a.Title
ORDER BY total_revenue DESC
LIMIT 10;


--Regional Revenue Breakdown
SELECT 
    BillingCountry AS country,
    COUNT(DISTINCT CustomerId) AS total_customers,
    COUNT(InvoiceId) AS total_invoices,
    ROUND(SUM(Total), 2) AS total_revenue,
    ROUND(AVG(Total), 2) AS avg_order_value
FROM Invoice
GROUP BY BillingCountry
ORDER BY total_revenue DESC
LIMIT 10;


--Monthly Sales Performance
SELECT 
    strftime('%Y-%m', InvoiceDate) AS sales_month,
    COUNT(InvoiceId) AS total_orders,
    ROUND(SUM(Total), 2) AS monthly_revenue
FROM Invoice
GROUP BY sales_month
ORDER BY sales_month ASC;


--Top Genre per Country (Window Function)
WITH RankedGenres AS (
    SELECT 
        i.BillingCountry AS country,
        g.Name AS genre_name,
        ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS total_spent,
        DENSE_RANK() OVER (
            PARTITION BY i.BillingCountry 
            ORDER BY SUM(il.UnitPrice * il.Quantity) DESC
        ) AS genre_rank
    FROM Invoice i
    JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
    JOIN Track t ON il.TrackId = t.TrackId
    JOIN Genre g ON t.GenreId = g.GenreId
    GROUP BY i.BillingCountry, g.GenreId, g.Name
)
SELECT 
    country,
    genre_name,
    total_spent
FROM RankedGenres
WHERE genre_rank = 1
ORDER BY total_spent DESC;