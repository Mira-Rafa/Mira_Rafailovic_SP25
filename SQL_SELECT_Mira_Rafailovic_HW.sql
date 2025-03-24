select f.title
from film f
join film_category fc on f.film_id = fc.film_id
join category c on fc.category_id  = c.category_id
where c.name = 'Animation'
and f.release_year between 2017 and 2019
and cast (f.rating as integer) > 1
order by f.title; 
--PART 1: task 1: All animation movies released between 2017 and 2019  with rate more than 1, alphabetical 

--task 2:The revenue earned by each rental store after March 2017
select i.store_id,
concat(a.address,' ',
COALESCE(a.address2,'')) as full_address,
sum (p.amount) as revenue from rental r 
join inventory i on r.inventory_id = i.inventory_id
join payment p on r.rental_id = p.rental_id
join store s on i.store_id =s.store_id
join address a on s.address_id = a.address_id
where r.rental_date > '2017-03-31'
group by i.store_id, full_address 
order by revenue desc;

--task 3:Top 5 actors by number of movies released after 2015
select a.first_name, a.last_name
COUNT (fa.film_id) as number_of_movies
from actor a
join film_actor fa on a.actor_id = fa.actor_id 
join film f on fa.film_id = f.film_id
where f.release_year > 2015
group by a.actor_id, a.first_name, a.last_name
order by number_of_movies desc 
limit 5;

--task 4: Count of movies per year by category
select f.release_year,
SUM (case when c.name = 'Drama' then 1 else 0 END) as
number_of_drama_movies,
SUM (case when c.name = 'Travel' then 1 else 0 END) as number_of_travel_movies,
SUM (case when c.name = 'Documentary' then 1 else 0 END) as number_of_documentary_movies
from film f
join film_category fc on f.film_id =fc.film_id
join category c on fc.category_id = c.category_id
group by f.release_year
order by f.release_year desc;

--PART 2: task 1: Which three employees generated the most revenue in 2017?
with StaffRevenue as (select p.staff_id, s.store_id,
SUM (p.amount) as total_revenue 
from payment p 
join staff s on p.staff_id = s.staff_id
where extract (year from p.payment_date) = 2017
group by p.staff_id, s.store_id),
LatestStore as (select s.staff_id,
MAX (s.store_id) as 
latest_store_id
from staff s
group by s.staff_id)
select sr.staff_id, ls.latest_store_id as store_id, sr.total_revenue
from StaffRevenue sr
join LatestStore ls on sr.staff_id = ls.staff_id
order by  sr.total_revenue desc
limit 3;

--Task 2: Top 5 most rented movies and their expected audience age
with MovieRentals as (
select f.title, f.rating, 
COUNT (r.rental_id) as rental_count
from rental r
join inventory i on r.inventory_id = i.inventory_id
join film f on i.film _id = f.film_id 
group by f.title, f.rating
order by rental_count desc 
limit 5)
select mr.title, mr.rental_count, mr.rating, 
case 
	when mr.rating ='G' then 'All Ages'
	when mr.rating ='PG' then '10+'
	when mr.rating ='PG-13' then '13+'
	when mr.rating ='R' then '17+'
	when mr.rating ='NC-17' then 'Adults Only (18+)'
	else 'Unknown Rating'
end as expected_audience
from MovieRentals mr;

-- PART 3: Which actors/actresses didn`t act for a longer period of time than the others? 
--Solution 1: Find the gap between the latest release year and the current year (2025)
select a.first_name, a.last_name,
MAX (f.release_year) as last_movie_year, 
2025 - MAX (f.release_year) as years_since_last_movie
from actor a 
join film_actor fa  on a.actor_id = fa.actor_id
join film f on fa.film_id = f.film_id
group by a.first_name, a.last_name
order by years_since_last_movie desc;
