Q1: Who is the senior most employee based on job title.
SELECT * FROM employee
ORDER BY levels desc
limit 1
Q2: Which countries have the most Invoices.
SELECT COUNT(*) AS c, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY c DESC;

Q3: What are top 3 values of total invoice.
SELECT total FROM invoice
order by total desc limit 3

___Q4: Which city has the best customers?
___We would like to throw a promotional Music Festival in the city where we made the most money.
___Write a query that returns one city that has the highest sum of invoice totals.
___Return both:
___1.City name
___2.Sum of all invoice totals

SELECT SUM(total) AS invoice_total, billing_city
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1;

___Q5.Who is the best customer?
___The customer who has spent the most money will be declared the best customer.
___Write a query that returns the person who has spent the most money.
___Return:
___1.Customer's full name.
___2.Total amount spent by the customer.

SELECT
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    SUM(invoice.total) AS total
FROM customer
JOIN invoice
    ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC
LIMIT 1;

Q6. Rock Music Listeners
Write a query to return the email, first name, last name, and genre of all Rock Music listeners.
Conditions:
1.Select only customers who listen to Rock music.
2.Return the following columns: Email, First Name, Last Name, and Genre.
3.Sort the results alphabetically by email.
4.Display only email addresses starting with the letter 'A'.

SELECT DISTINCT email, first_name, last_name
FROM customer
JOIN invoice
    ON customer.customer_id = invoice.customer_id
JOIN invoice_line
    ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN (
    SELECT track_id
    FROM track
    JOIN genre
        ON track.genre_id = genre.genre_id
    WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

Q7. Top 10 Rock Artists.
Let's invite the artists who have written the most rock music in our dataset.
Write a SQL query that returns the Artist Name and Total Track Count of the top 10 rock bands.
SELECT
    artist.artist_id,
    artist.name,
    COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album
    ON album.album_id = track.album_id
JOIN artist
    ON artist.artist_id = album.artist_id
JOIN genre
    ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id, artist.name
ORDER BY number_of_songs DESC
LIMIT 10;

Q8:
Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track.
Order by song length, with the longest songs listed first.

SELECT name, milliseconds
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds) AS avg_track_length
    FROM track
)
ORDER BY milliseconds DESC;

Find how much amount each customer has spent on each artist.
Q9:Write a SQL query to return the following columns:
1. Customer Name
2. Artist Name
3. Total Spent

WITH best_selling_artist AS (
    SELECT
        artist.artist_id AS artist_id,
        artist.name AS artist_name,
        SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM invoice_line
    JOIN track
        ON track.track_id = invoice_line.track_id
    JOIN album
        ON album.album_id = track.album_id
    JOIN artist
        ON artist.artist_id = album.artist_id
    GROUP BY artist.artist_id
    ORDER BY total_sales DESC
    LIMIT 1
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    bsa.artist_name,
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c
    ON c.customer_id = i.customer_id
JOIN invoice_line il
    ON il.invoice_id = i.invoice_id
JOIN track t
    ON t.track_id = il.track_id
JOIN album alb
    ON alb.album_id = t.album_id
JOIN best_selling_artist bsa
    ON bsa.artist_id = alb.artist_id
GROUP BY 1, 2, 3, 4
ORDER BY 5 DESC;

Q9:We want to find out the most popular music genre for each country.
We determine the most popular genre as the genre with the highest number of purchases.
Write a SQL query that returns each country along with its top genre.
For countries where the maximum number of purchases is shared, return all genres.

WITH popular_genre AS
(
    SELECT
        COUNT(invoice_line.quantity) AS purchases,
        customer.country,
        genre.name,
        genre.genre_id,
        ROW_NUMBER() OVER (
            PARTITION BY customer.country
            ORDER BY COUNT(invoice_line.quantity) DESC
        ) AS RowNo
    FROM invoice_line
    JOIN invoice
        ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer
        ON customer.customer_id = invoice.customer_id
    JOIN track
        ON track.track_id = invoice_line.track_id
    JOIN genre
        ON genre.genre_id = track.genre_id
    GROUP BY 2, 3, 4
    ORDER BY 2 ASC, 1 DESC
)
SELECT *
FROM popular_genre
WHERE RowNo <= 1;

Q10:Write a SQL query that determines the customer who has spent the most money on music for each country.
Return the following information:
1. Country
2. Top Customer
3. Total Amount Spent
For countries where the highest amount spent is shared by multiple customers, return all customers who spent that amount.

WITH Customer_with_country AS (
    SELECT
        customer.customer_id,
        first_name,
        last_name,
        billing_country,
        SUM(total) AS total_spending,
        ROW_NUMBER() OVER (
            PARTITION BY billing_country
            ORDER BY SUM(total) DESC
        ) AS RowNo
    FROM invoice
    JOIN customer
        ON customer.customer_id = invoice.customer_id
    GROUP BY 1, 2, 3, 4
    ORDER BY 4 ASC, 5 DESC
)
SELECT *
FROM Customer_with_country
WHERE RowNo <= 1;