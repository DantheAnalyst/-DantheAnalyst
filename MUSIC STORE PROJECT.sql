/*1. Who is the senior most employee based on job title? */
SELECT  
	employee_id,
	first_name ||''|| last_name AS full_name,
	title
FROM employee
WHERE reports_to IS NULL;

/*2. Which countries have the most Invoices? */

SELECT
    billing_country,
    COUNT(invoice_id) AS total_invoices
FROM 
    invoice
GROUP BY
    billing_country
ORDER BY
    total_invoices DESC
LIMIT 1;

/*3.What are top 3 values of total invoice? */

SELECT
    COUNT(invoice_id) AS total_invoices
FROM 
    invoice
GROUP BY
    billing_country
ORDER BY
    total_invoices DESC
LIMIT 3;

/*4.Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals*/

SELECT 
	billing_city,
	CAST(SUM(total)AS INT) AS total_invoice_amount
FROM 
	invoice
GROUP BY
	billing_city
ORDER BY 
	total_invoice_amount DESC
LIMIT 1;

/*5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money */

SELECT 
	c.customer_id,
	c.first_name ||''|| c.last_name AS full_name,
	CAST(SUM(total)AS INT) AS total_money_spent
FROM 
	customer c
JOIN 
	invoice i
USING(customer_id)
	
GROUP BY 
	c.customer_id, full_name
ORDER BY 
	total_money_spent DESC
LIMIT 1;
	
/*6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A*/

SELECT 
	c.customer_id,
	c.first_name,
	c.last_name,
	c.email,
	g.name AS genre_name
FROM 
	customer c
JOIN 
	invoice i
USING(customer_id)
JOIN
	invoice_line il
USING(invoice_id)
JOIN 
	track t
USING(track_id)
JOIN 
	genre g
USING(genre_id)
WHERE 
	g.name = 'Rock'
ORDER BY 
	email;

/*7. Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands*/

SELECT
	a.artist_id,
	a.name AS artist_name,
	g.name AS genre_name,
	COUNT(t.track_id) AS total_track
FROM 
	artist a
JOIN album al
USING(artist_id)
JOIN
	track t
USING(album_id)
JOIN 
	genre g
USING(genre_id)
GROUP BY a.artist_id, a.name,g.name
HAVING g.name = 'Rock'
ORDER BY total_track DESC
LIMIT 10;

/*8. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first*/

SELECT 
	name AS track_name,
	milliseconds AS song_length
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY song_length DESC;

/*9. Find how much amount spent by each customer on artists?
Write a query to return customer name, artist name and total spent*/

SELECT
    c.first_name || ' ' || c.last_name AS customer_name,
    a.name AS artist_name,
    SUM(il.unit_price * il.quantity) AS total_spent
FROM
    customer c
JOIN
    invoice i 
USING(customer_id)
JOIN
    invoice_line il 
USING(invoice_id)
JOIN
    track t 
USING(track_id)
JOIN
    album al 
USING(album_id)
JOIN
    artist a 
USING(artist_id)
GROUP BY
    c.customer_id, a.artist_id
ORDER BY
    customer_name, total_spent DESC;


/*10. We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases. 
Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared return all Genres*/
WITH RankedGenres AS (
    SELECT
        i.billing_country,
        g.name AS genre_name,
        RANK() OVER (PARTITION BY i.billing_country ORDER BY COUNT(il.track_id) DESC) AS genre_rank
    FROM
        invoice i
    JOIN
        invoice_line il 
	USING(invoice_id)
    JOIN
        track t 
	USING(track_id)
    JOIN
        genre g 
	USING(genre_id)
    GROUP BY
        i.billing_country, g.name
)
SELECT
    billing_country,
    genre_name
FROM
    RankedGenres
WHERE
    genre_rank = 1;


/*11. Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount*/

WITH RankedCustomers AS (
    SELECT
        i.billing_country,
        c.first_name || ' ' || c.last_name AS customer_name,
        SUM(il.unit_price * il.quantity) AS total_spent,
        RANK() OVER (PARTITION BY i.billing_country ORDER BY SUM(il.unit_price * il.quantity) DESC) AS customer_rank
    FROM
        invoice i
    JOIN
        customer c 
	USING(customer_id)
    JOIN
        invoice_line il 
	USING(invoice_id)
    GROUP BY
        i.billing_country, c.customer_id
)
SELECT
    billing_country,
    customer_name,
    total_spent
FROM
    RankedCustomers
WHERE
    customer_rank = 1;

	

	

	


	








