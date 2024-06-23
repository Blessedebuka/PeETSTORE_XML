-- ANALYSIS ON THE MUSIC_STORE DATASET
create database music_store;
use music_store;
select * from album;
select * from customer;
select * from employee;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media_type;
select * from playlist_track;
select * from track;
select * from artist;

-- QUESTIONS
-- 1. WHO IS THE SENIOR MOST EMPLOYED BASE ON JOB TITLE?
select * from employee 
where levels = (select MAX(levels) from employee);

-- 2.WHICH COUNTRIES HAVE THE MOST INVOICES?
select billing_country, count(*) as invoice_count
from invoice group by billing_country order by invoice_count desc;

--3.TOP 3 VALUES OF TOTAL INVOICES?
select top 3 total from invoice order by total desc;

--4. CITY WITH THE BEST CUSTOMERS. WRITE A QUERY THAT WILL RETURN
-- THE CITY NAME AND SUM OF THE TOTAL INVOICES GENERATED.
select * from 
(select billing_city, SUM(total) as total_invoice, ROW_NUMBER()
over(order by sum(total) desc) as row_num
from invoice group by billing_city, total)j where j.row_num = 1;

-- 5. THE CUSTOMER WITH THE HIGHEST MONEY SPENT - THE BEST CUSTOMER
select top 1 c.customer_id, c.first_name, c.last_name, 
SUM(i.total) as total_money from customer c
inner join invoice i on c.customer_id = i.customer_id
group by c.customer_id, c.first_name, c.last_name
order by total_money desc; 

-- 6.RETURN EMAIL, FIRSTNAME, LASTNAME AND GENRE OF ALL
-- ROCKMUSIC LISTENER. RETURN THE LIST ORDERED ALPHABETICALLY
select distinct first_name, last_name, email
from customer, genre, track
where genre.name = 'Rock' and genre.genre_id = track.genre_id
order by email asc;

-- 7. RETURN ARTIST NAME AND THE TOTAL TRACK COUNT OF THE TOP 10 ROCK BANDS
-- ARTIST WHO HAVE WRITTEN THE MOST ROCK MUSIC
select top 10 artist.artist_id, artist.name,
count(track.track_id) as total_count from track join
album on album.album_id = track.album_id join artist on
artist.artist_id = album.artist_id join genre on genre.genre_id =
track.genre_id where genre.name = 'Rock'
group by artist.artist_id, artist.name order by total_count desc;

-- QUESTION 7- RETURN ALL THE SONG NAMES THAT HAVE SONG LENGTH
-- GREATER THAN THE AVERAGE SONG LENGTH
select name, milliseconds from track where
 milliseconds > (select AVG(milliseconds) from track)
order by milliseconds desc;

-- QUESTION 8- RETURN CUSTOMER NAME, ARTIST NAME AND MONEY THEY SPENT
-- ON THE HIGHEST EARNING ARTIST- GET THE BEST SELLING ARTIST
-- FIND OUT HOW MUCH EACH CUSTOMER PAID
With cte_main As
(SELECT top 1 ar.artist_id,ar.name as artist_name, SUM(il.unit_price*il.quantity)
as total_sales from invoice_line il join track t
on il.track_id=t.track_id join album a on a.album_id=
t.album_id join artist ar on ar.artist_id =a.artist_id
group by ar.artist_id,ar.name order by total_sales desc)
select c.customer_id, c.first_name, c.last_name, cte_main.artist_name,
SUM(il.unit_price*il.quantity) as money_spent from invoice i join
customer c on c.customer_id=i.customer_id join invoice_line il on
i.invoice_id=il.invoice_id join track t on il.track_id=t.track_id
join album al on t.album_id=al.album_id join cte_main
on cte_main.artist_id=al.artist_id group by
c.customer_id, c.first_name, c.last_name, cte_main.artist_name
order by money_spent desc;

-- QUESTION 9 - THE MOST POPULAR MUSIC GENRE FOR EACH COUNTRY- WE
-- DO THIS BY GETTING THE GENRE WITH THE HIGHEST PURCHASE, IE, QUANTITY
with cte_main as
(select c.country as country, g.name as genre_name, g.genre_id,
count(il.quantity) as total_purchase, ROW_NUMBER() over
(partition by c.country order by count(il.quantity) desc)
as count_purchase from invoice_line il
join invoice i on i.invoice_id=il.invoice_id join
customer c on c.customer_id=i.customer_id join track t
on il.track_id=t.track_id join genre g on t.genre_id=
g.genre_id group by c.country, g.name, g.genre_id)
select * from cte_main where count_purchase <=1
order by cte_main.country, total_purchase desc

-- QUESTION 10- CUSTOMER THAT HAVE SPENT THE MOST MONEY ON MUSIC
-- FOR EACH COUNTRY. FOR COUNTRIES WITH THE TOP AMOUNT SHARED,
-- PROVIDE ALL CUSTOMERS WITH THE  LRADING VALUES
select * from 
(
select c.customer_id, c.first_name, c.last_name,i.billing_country,
SUM(i.total) as money_spent,
ROW_NUMBER() over (partition by i.billing_country order by
 SUM(i.total) desc)
as row_num from invoice i join
customer c on c.customer_id=i.customer_id
group by
c.customer_id, c.first_name, c.last_name,i.billing_country
)m where m.row_num <=1 order by m.money_spent desc;