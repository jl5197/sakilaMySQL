USE sakila

-- 1a Display the first and last names of all actors from the table actor
SELECT first_name, last_name FROM actor; 

-- 1b Display the first and last name of each actor in a single column in upper case letters.
SELECT CONCAT(first_name, ' ', last_name) AS 'Actor Name' FROM actor;

-- 2a Find the ID number, first name, and last name of an actor whose first name is "Joe."
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = 'JOE';

-- 2b All actors whose last name contain the letters 'GEN'
SELECT actor_id, first_name, last_name FROM actor WHERE last_name LIKE '%GEN%';

-- 2c All actors whose last names contain the letters 'LI'
SELECT actor_id, last_name, first_name FROM actor WHERE last_name LIKE '%LI%';

-- 2d Display the country_id and country columns of the following countries: 'Afghanistan', 'Bangladesh', and 'China'
SELECT c.country_id, c.country FROM country c 
WHERE c.country IN ('Afghanistan', 'Bangladesh', 'China'); 

-- 3a Create a column in the table actor called description and use the data type BLOB
ALTER TABLE actor
ADD COLUMN description BLOB AFTER last_name;

-- 3b Delete the description column
ALTER TABLE actor
DROP COLUMN description; 

-- 4a List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS 'Total Number of Actors with THIS last_name' 
FROM actor GROUP BY last_name;

-- 4b List last names of actors and the number of actors who have that last name (only for names that are shared by at least two actors)
SELECT last_name, COUNT(last_name) AS 'Total Number of Actors with THIS last_name' 
FROM actor GROUP BY last_name HAVING COUNT('Total Number of Actors with THIS last_name') > 1; 

-- 4c Change the actor 'HARPO WILLIAMS' to 'GROUCHO WILLIAMS'
UPDATE actor SET first_name = 'HARPO' WHERE last_name = 'WILLIAMS' AND first_name = 'GROUCHO'; 

-- 4d Revert the first name of the actor named 'HARPO' to 'GROUCHO'.
SET SQL_SAFE_UPDATES = 0;
UPDATE actor SET first_name = 'GROUCHO' WHERE first_name = 'HARPO'; 
SET SQL_SAFE_UPDATES = 1;

-- 5a Create a table called 'address'
SHOW CREATE TABLE address;

-- 6a Join the table of staff and address
SELECT staff_id, first_name, last_name FROM staff
INNER JOIN address ON staff.address_id = address.address_id; 

-- 6b Join the table of staff and payment
SELECT staff.staff_id, staff.first_name, staff.last_name, SUM(amount) AS 'Total Amount' FROM payment 
INNER JOIN staff ON staff.staff_id = payment.staff_id GROUP BY staff.staff_id;

-- 6c List each film and the number of actors who are listed for that film
SELECT film.film_id, film.title, COUNT(DISTINCT film_actor.actor_id) AS 'Number of Actors' FROM film
INNER JOIN film_actor ON film_actor.film_id = film.film_id GROUP BY film.film_id; 

-- 6d Display the number of copies of the film 'Hunchback Impossible' exist in the inventory system
SELECT film.film_id, film.title, COUNT(inventory.film_id) AS 'Number of Copies in inventory' FROM film 
INNER JOIN inventory ON inventory.film_id = film.film_id GROUP BY film.film_id HAVING film.title = 'Hunchback Impossible'; 

-- 6e Join the table of payment and customer to display the total amount paid by each customer
SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS 'Total Amount Paid' FROM customer
LEFT JOIN payment ON payment.customer_id = customer.customer_id GROUP BY payment.customer_id 
ORDER BY customer.last_name ASC; 

-- 7a Display the titles of movies starting with the letters K and Q whose language is English.
SELECT film.film_id, film.title, film.language_id FROM film WHERE film.title LIKE 'K%' OR film.title LIKE 'Q%' AND film.language_id 
IN (SELECT language.language_id FROM language WHERE language.name = 'English'); 

-- 7b Display all actors who appear in the film 'Alone Trip'
SELECT actor_id, first_name, last_name FROM actor 
WHERE actor_id IN (SELECT actor_id FROM film_actor 
					WHERE film_id IN (SELECT film_id FROM film WHERE title = 'Alone Trip'));

-- 7c Retrieve the names and email addresses of all Canadian customers. 
SELECT customer_id, CONCAT(first_name, ' ', last_name) AS 'Customer', email FROM customer 
WHERE address_id IN (SELECT address_id FROM address 
					 WHERE city_id IN (SELECT city_id FROM city 
                     WHERE country_id IN (SELECT country_id FROM country WHERE country = 'Canada')));

-- 7d Identify all movies categorized as family films.
SELECT film_id, title FROM film 
WHERE film_id IN (SELECT film_id FROM film_category 
				  WHERE category_id IN (SELECT category_id FROM category WHERE name = 'Family'));

-- 7e Display the most frequently rented movies in descending order.
SELECT f.film_id, f.title, COUNT(r.rental_id) AS 'Times of Rental' FROM rental r 
LEFT JOIN inventory i ON i.inventory_id = r.inventory_id 
LEFT JOIN film f ON f.film_id = i.film_id GROUP BY f.film_id ORDER BY f.title DESC; 

-- 7f Display how much business, in dollars, each store brought in.
SELECT s.store_id, a.address, SUM(p.amount) AS 'Revenue' FROM store s
LEFT JOIN payment p ON p.staff_id = s.manager_staff_id 
LEFT JOIN address a ON a.address_id = s.address_id GROUP BY s.manager_staff_id; 

-- 7g Display for each store its store ID, city, and country.
SELECT s.store_id, ci.city, co.country FROM store s
LEFT JOIN address a ON a.address_id = s.address_id 
LEFT JOIN city ci ON ci.city_id = a.city_id 
LEFT JOIN country co ON co.country_id = ci.country_id; 

-- 7h List the top five genres in gross revenue in descending order.
SELECT c.category_id, c.name AS 'category_name', SUM(p.amount) AS 'Gross Revenue' FROM category c 
LEFT JOIN film_category fc ON fc.category_id = c.category_id
LEFT JOIN inventory i ON i.film_id = fc.film_id
LEFT JOIN rental r ON r.inventory_id = i.inventory_id
LEFT JOIN payment p ON p.customer_id = r.customer_id 
GROUP BY c.category_id ORDER BY SUM(p.amount) DESC; 

-- 8a Create a View of 7h
CREATE TABLE top_five_genres AS 
SELECT c.category_id, c.name AS 'category_name', SUM(p.amount) AS 'Gross Revenue' FROM category c 
LEFT JOIN film_category fc ON fc.category_id = c.category_id
LEFT JOIN inventory i ON i.film_id = fc.film_id
LEFT JOIN rental r ON r.inventory_id = i.inventory_id
LEFT JOIN payment p ON p.customer_id = r.customer_id 
GROUP BY c.category_id ORDER BY SUM(p.amount) DESC; 

CREATE VIEW top_five_genres_view AS 
SELECT category_id, category_name, `Gross Revenue` FROM top_five_genres;

-- 8b Display the view created from 8a
SELECT * FROM top_five_genres_view;

-- 8c Delete the view 
DROP VIEW top_five_genres_view;
