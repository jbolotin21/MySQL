/* 1a. Display the first and last names of all actors from the table `actor`.*/
select first_name, last_name from actor;

/* 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.*/
SELECT CONCAT(UCASE(first_name), " ", UCASE(last_name)) as "Actor Name"
FROM actor;

/* 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?*/
select actor_id, first_name, last_name from actor
where first_name = 'Joe';

/* 2b. Find all actors whose last name contain the letters `GEN`:*/
select first_name, last_name from actor
where last_name like '%GEN%';

/* 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:*/
select first_name, last_name from actor
where last_name like '%LI%'
order by last_name, first_name;

/* 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:*/
select country_id, country from country
where country in ('Afghanistan', 'Bangladesh', 'China')

/* 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.*/
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(30) AFTER first_name;

/* 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.*/
ALTER TABLE actor MODIFY middle_name BLOB;

/* 3c. Now delete the `middle_name` column.*/
ALTER TABLE actor DROP middle_name;

/* 4a. List the last names of actors, as well as how many actors have that last name.*/
select last_name, count(last_name) from actor
group by last_name;

/* 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors*/
select last_name, count(last_name) from actor
group by last_name
having count(last_name) > 1;

/* 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.*/
UPDATE actor
SET first_name = 'HARPO' 
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

/* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)*/
UPDATE actor
SET first_name = 
	CASE 
		WHEN first_name = "HARPO"
			THEN "GROUCHO"
		ELSE "MUCHO GROUCHO"
	END
WHERE actor_id = 172;

/* 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
  * Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>*/
SHOW CREATE TABLE  sakila.address;

/* 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:*/
select staff.first_name, staff.last_name, address.address, address.address2, address.district, address.postal_code
FROM staff
JOIN address ON
staff.address_id = address.address_id;

/* 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.*/
select staff.first_name, staff.last_name, sum(payment.amount)
FROM staff
JOIN payment ON
staff.staff_id = payment.staff_id
where payment.payment_date between '2005-07-31' and '2005-09-01'
group by first_name;

/* 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.*/
select film.title, count(film_actor.actor_id) as num_actors
FROM film
INNER JOIN film_actor ON
film.film_id = film_actor.film_id
group by film.title;

/* 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?*/
select film.title, count(inventory.film_id) as copies
FROM film
INNER JOIN inventory ON
film.film_id = inventory.film_id
where film.title = 'Hunchback Impossible';

/* 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:*/
select customer.first_name, customer.last_name, sum(payment.amount) as total_paid
FROM customer
INNER JOIN payment ON
customer.customer_id = payment.customer_id
group by customer.customer_id
order by customer.last_name;

/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.*/
SELECT f.film_id, f.title
FROM film as f
INNER JOIN `language` as l
ON f.language_id = l.language_id
and l.name = 'English'
and (f.title like 'k%' or f.title like 'q%');

/* 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.*/
SELECT a.first_name, a.last_name
FROM actor as a
INNER JOIN film_actor as fa
on a.actor_id = fa.actor_id
WHERE fa.film_id IN
	(SELECT f.film_id
	FROM film as f
    WHERE f.title = 'Alone Trip');

/* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.*/
select customer.first_name, customer.last_name, customer.email
from customer
join address
on customer.address_id = address.address_id
join city
on address.city_id = city.city_id
join country
on city.country_id = country.country_id
where country.country = 'Canada';

/* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.*/
select film.title
from film
join film_category
on film.film_id = film_category.film_id
join category
on film_category.category_id = category.category_id
where category.name = 'Family';

/* 7e. Display the most frequently rented movies in descending order.*/
SELECT f.title, COUNT(r.inventory_id) as NumRents
FROM rental as r
INNER JOIN inventory as i
ON r.inventory_id = i.inventory_id
INNER JOIN film as f
ON i.film_id = f.film_id
GROUP BY f.film_id, f.title
ORDER BY COUNT(r.inventory_id) DESC;

/* 7f. Write a query to display how much business, in dollars, each store brought in.*/
SELECT s.store_id, sum(amount) as Revenue FROM store as s
RIGHT JOIN staff as st
ON s.store_id = st.store_id
LEFT JOIN payment as p
ON st.staff_id = p.staff_id
GROUP BY s.store_id;

/* 7g. Write a query to display for each store its store ID, city, and country.*/
SELECT s.store_id, ci.city, co.country FROM store as s
JOIN address as a
ON s.address_id = a.address_id
JOIN city ci
ON a.city_id = ci.city_id
JOIN country as co
ON ci.country_id = co.country_id;

/* 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)*/
SELECT c.name, sum(p.amount) as "Revenue per Category" FROM category c
JOIN film_category as fc
ON c.category_id = fc.category_id
JOIN inventory as i
ON fc.film_id = i.film_id
JOIN rental as r
ON r.inventory_id = i.inventory_id
JOIN payment as p
ON p.rental_id = r.rental_id
GROUP BY name
ORDER BY sum(p.amount) desc
limit 5;

/* 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.*/
CREATE VIEW top_5_by_genre AS
SELECT c.name, sum(p.amount) as "Revenue per Category" FROM category c
JOIN film_category as fc
ON c.category_id = fc.category_id
JOIN inventory as i
ON fc.film_id = i.film_id
JOIN rental as r
ON r.inventory_id = i.inventory_id
JOIN payment as p
ON p.rental_id = r.rental_id
GROUP BY name
ORDER BY sum(p.amount) desc
limit 5;

/* 8b. How would you display the view that you created in 8a?*/
SELECT * FROM top_5_by_genre;

/* 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.*/
DROP VIEW top_5_by_genre;