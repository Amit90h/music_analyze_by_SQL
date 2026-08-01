--Easy

--Q 1 who is the senior must employee base on the job title

select * from employee
order by levels desc 
limit 1;

--Q 2 which country have the most invoice 

select count(*) as total_invoices, billing_countr
from invoice
group by billing_country
order by billing_country desc;



-- Q 3 what are top 3 values of total invoice

select total from invoice
order by total desc
limit 3;

-- Q 4 which city has the best customers? 
---we would like to throw a promotional music festival in the city
---we made the most money. write a query that returns one city that has the highest sum of invoice totals
-- return both the city name & sum of all invoice totals

select billing_city, sum(total) as revenue 
from invoice 
group by billing_city
order by revenue desc
limit 1;


--Q 5 who is the best customer? 
--the customer who has spent the most money will be declared the best customer 
--.write a query that returns the person who has spent the most money

select customer.customer_id, customer.first_name,customer.last_name,
sum(invoice.total) as spent_money 
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by spent_money desc
limit 1;

-- moderate level

-- Q 1 write a query return email and first name ,last name also genre of all rock music listeners 
--return your list order by email alphabetically start a


SELECT DISTINCT email, first_name,last_name
FROM customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in (
SELECT track_id FROM track
join genre on track.genre_id = genre.genre_id
where genre.name = 'Rock')
order by email asc;


-- Q 2 lets invite the artists who have written the most like rock music in our dataset
-- writen the query that returns the artist name and total track count of the top 10 rock brands
SELECT artist.artist_id,artist.name, count(artist.artist_id) AS Number_of_song
FROM track
JOIN album ON track.album_id = album.album_id
JOIN artist ON album.artist_id = artist.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY Number_of_song DESC
LIMIT 10;


-- Q 3 Return the all track names that have a song length longer than  the average song length. 
-- return the name  and millisecond of each track. 
-- order by the song length with the longest songs listed first

SELECT track_id,name,milliseconds
FROM track
WHERE milliseconds >(
SELECT AVG(milliseconds) as avg_length_song
FROM track
)
ORDER BY milliseconds DESC;


-- Adevnce Question
-- Q 1 Find how much money spent by each Customer artists ?
-- Write To Query customer name and artist and  total spent money ?


WITH salling_data AS (

SELECT artist.artist_id as artist_id,
artist.name as artist_name,
SUM(invoice_line.unit_price * invoice_line.quantity) as total_sales
FROM invoice_line
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
GROUP BY  1
ORDER BY  3 DESC
LIMIT 1

)

SELECT c.customer_id,c.first_name,c.last_name,sd.artist_name,
SUM(il.unit_price*il.quantity) as total_sales
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id= il.track_id
JOIN album al ON al.album_id = t.album_id
JOIN salling_data sd ON sd.artist_id = al.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


-- Q 2
-- we want find out most popular music genre for each country.
-- we determine the most popular genre as the genre with heghest amount of purchases
-- write a query that returns each country along with top genre.
-- for counties where the maxmum number of purchases is returned all genres

WITH best_country_sales as (

SELECT COUNT(invoice_line.quantity) as purchases,customer.country,genre.name, genre.genre_id,
ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) desc)as rowno
FROM invoice_line
JOIN invoice ON invoice_line.invoice_id = invoice.invoice_id
JOIN customer ON customer.customer_id = invoice.customer_id
JOIN track ON track.track_id= invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
GROUP BY 2,3,4
ORDER BY 2 ASC, 1 DESC

)

SELECT * FROM best_country_sales 
WHERE rowno <=1;



-- Q 3
-- Write a query that determines the customer that has spent the most on music for each country.
-- Write a query that returns the country along with the top customer how much they spent.
-- for counties where the top amount spent is shared , provide all customers who spent this amount 


WITH 
	RECURSIVE customer_behavior as
	(
		SELECT customer.customer_id , first_name ,last_name,billing_country ,
		sum(total) as total_spent
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY  2,3 DESC
	),
	max_spenting as 
	(
		SELECT billing_country,MAX(total_spent) as max_spent
		FROM customer_behavior
		GROUP BY billing_country
	)

SELECT cc.billing_country,cc.total_spent,cc.first_name,cc.last_name, cc.customer_id
FROM customer_behavior cc
JOIN max_spenting ms ON ms.billing_country = cc.billing_country
WHERE cc.total_spent = ms.max_spent
ORDER BY 1;


-- Second Method
WITH customer_behaior as(
SELECT customer.customer_id,first_name,last_name,billing_country,sum(total)as total_spent,
ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY sum(total) desc) as rowno
FROM invoice
JOIN customer ON customer.customer_id = invoice.customer_id
GROUP BY 1,2,3,4
ORDER BY 4 ASC, 5 DESC
)
SELECT * FROM customer_behaior
WHERE rowno <= 1;
