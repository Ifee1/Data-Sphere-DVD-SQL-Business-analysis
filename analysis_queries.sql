-- 1.  Identify the manager responsible for each store and retrieve the complete address details of the store location.
select first_name, last_name, address, district, city, country
from staff
join address
on staff.address_id = address.address_id
join city
on city.city_id = address.city_id
join country
on country.country_id = city.country_id

-- 2. Inventory Portfolio Inspection
-- Retrieve a detailed inventory dataset containing the store identifier, inventory identifier, film information, rental pricing, and replacement cost for each stocked item.

select inventory_id, store_id, title as name_of_film, rating as film_rating, rental_rate, replacement_cost
 from inventory
 join film
 on inventory.film_id = film.film_id
________________________________________
-- 3. Film Rating Distribution Across Stores
-- Aggregate inventory data to determine how many films of each rating are available at each store.

select store_id, rating,
count(inventory_id) as num_of_film
from inventory
left join film
on inventory.film_id = film.film_id 
group by store_id, rating
________________________________________
-- 4. Inventory Replacement Cost Exposure
-- Evaluate the financial exposure of inventory by analyzing the number of films, average replacement cost, and total replacement cost by store and film category.

  SELECT 
	store_id, 
    category.name AS category, 
	COUNT(inventory.inventory_id) AS films, 
    AVG(film.replacement_cost) AS avg_replacement_cost, 
    SUM(film.replacement_cost) AS total_replacement_cost
    
from inventory
	left join film
		on inventory.film_id = film.film_id
	left join film_category
		on film.film_id = film_category.film_id
	left join category
		on category.category_id = film_category.category_id

group by
	store_id, 
    category.name
    
order by
	SUM(film.replacement_cost) desc
________________________________________
-- 5. Customer Demographic Overview
-- Generate a dataset of customers including store affiliation, activity status, and complete address information.
select first_name, last_name, store_id, address.address, address.district, city.city, country.country,
case when active = 1 then active = 1
when active = 0 then active = 0
end as customer_status
from customer
join address
on customer.address_id = address.address_id
join city
on address.city_id = city.city_id
join country
on city.country_id = country.country_id
	
-- 6. Customer Value Ranking
-- Determine customer lifetime value by calculating total rentals and total payments made by each customer, ranked from highest to lowest spending customers.
select customer.first_name, customer.last_name, customer.customer_id,
sum(inventory_id) as total_rentals,
sum(amount) as total_payment
from rental
join customer
on rental.customer_id = customer.customer_id
join payment
on payment.rental_id = rental.rental_id
group by customer.first_name, customer.last_name, customer.customer_id
order by sum(inventory_id), sum(amount) desc
________________________________________
-- 7. Organizational Stakeholder Directory
-- Compile a consolidated dataset listing both advisors and investors, identifying their roles and associated companies where applicable.
Select 'Investor' as type,
first_name, last_name, company_name
from investor

union

select 'Advisor' as type,
first_name, last_name, null
from advisor
________________________________________
-- 8. Award-Winning Actor Coverage
-- Measure the representation of award-winning actors in the film catalog, calculating the percentage coverage for actors with one, two, and three award types.
SELECT
	CASE 
		WHEN actor_award.awards = 'Emmy, Oscar, Tony ' THEN '3 awards'
        WHEN actor_award.awards IN ('Emmy, Oscar','Emmy, Tony', 'Oscar, Tony') THEN '2 awards'
		ELSE '1 award'
	END AS number_of_awards, 
    AVG(CASE WHEN actor_award.actor_id IS NULL THEN 0 ELSE 1 END) AS pct_w_one_film
	
from actor_award
	group by
	case 
		WHEN actor_award.awards = 'Emmy, Oscar, Tony ' THEN '3 awards'
        WHEN actor_award.awards IN ('Emmy, Oscar','Emmy, Tony', 'Oscar, Tony') THEN '2 awards'
		ELSE '1 award'
	end
