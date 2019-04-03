USE sakila

-- 1a 
SELECT first_name, last_name FROM actor; 

-- 1b
SELECT CONCAT(first_name, ' ', last_name) AS 'Actor Name' FROM actor;

-- 2a
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = 'JOE';

-- 2b
SELECT actor_id, first_name, last_name FROM actor WHERE last_name LIKE '%GEN%';

-- 2c
SELECT actor_id, last_name, first_name FROM actor WHERE last_name LIKE '%LI%';

-- 2d
SELECT c.country_id, c.country FROM country c 
WHERE c.country IN ('Afghanistan', 'Bangladesh', 'China'); 

-- 3a
ALTER TABLE actor
ADD COLUMN description BLOB AFTER last_name;

-- 3b
ALTER TABLE actor
DROP COLUMN description; 

-- 4a
SELECT last_name, COUNT(last_name) AS 'Total Number of Actors with THIS last_name' 
FROM actor GROUP BY last_name;

-- 4b
SELECT last_name, COUNT(last_name) AS 'Total Number of Actors with THIS last_name' 
FROM actor GROUP BY last_name HAVING COUNT('Total Number of Actors with THIS last_name') > 1; 

-- 4c
UPDATE actor SET first_name = 'HARPO' WHERE last_name = 'WILLIAMS' AND first_name = 'GROUCHO'; 

-- 4d
SET SQL_SAFE_UPDATES = 0;
UPDATE actor SET first_name = 'GROUCHO' WHERE first_name = 'HARPO'; 
SET SQL_SAFE_UPDATES = 1;

-- 5a 
SHOW CREATE TABLE address;

-- 6a
SELECT staff_id, first_name, last_name FROM staff
INNER JOIN address ON staff.address_id = address.address_id; 

-- 6b
SELECT staff.staff_id, staff.first_name, staff.last_name, SUM(amount) AS 'Total Amount' FROM payment 
INNER JOIN staff ON staff.staff_id = payment.staff_id GROUP BY staff.staff_id;

-- 6c 
SELECT film.film_id, film.title, COUNT(DISTINCT film_actor.actor_id) AS 'Number of Actors' FROM film
INNER JOIN film_actor ON film_actor.film_id = film.film_id GROUP BY film.film_id; 

-- 6d
SELECT film.film_id, film.title, COUNT(inventory.film_id) AS 'Number of Copies in inventory' FROM film 
INNER JOIN inventory ON inventory.film_id = film.film_id GROUP BY film.film_id HAVING film.title = 'Hunchback Impossible'; 

-- 6e
SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS 'Total Amount Paid' FROM customer
LEFT JOIN payment ON payment.customer_id = customer.customer_id GROUP BY payment.customer_id 
ORDER BY customer.last_name ASC; 

-- 7a 
SELECT film.film_id, film.title, film.language_id FROM film WHERE film.title LIKE 'K%' OR film.title LIKE 'Q%' AND film.language_id 
IN (SELECT language.language_id FROM language WHERE language.name = 'English'); 

-- 7b 
SELECT actor_id, first_name, last_name FROM actor 
WHERE actor_id IN (SELECT actor_id FROM film_actor 
					WHERE film_id IN (SELECT film_id FROM film WHERE title = 'Alone Trip'));

-- 7c
SELECT customer_id, CONCAT(first_name, ' ', last_name) AS 'Customer', email FROM customer 
WHERE address_id IN (SELECT address_id FROM address 
					 WHERE city_id IN (SELECT city_id FROM city 
                     WHERE country_id IN (SELECT country_id FROM country WHERE country = 'Canada')));

-- 7d
SELECT film_id, title FROM film 
WHERE film_id IN (SELECT film_id FROM film_category 
				  WHERE category_id IN (SELECT category_id FROM category WHERE name = 'Family'));

-- 7e
SELECT f.film_id, f.title, COUNT(r.rental_id) AS 'Times of Rental' FROM rental r 
LEFT JOIN inventory i ON i.inventory_id = r.inventory_id 
LEFT JOIN film f ON f.film_id = i.film_id GROUP BY f.film_id ORDER BY f.title DESC; 

-- 7f
SELECT s.store_id, a.address, SUM(p.amount) AS 'Revenue' FROM store s
LEFT JOIN payment p ON p.staff_id = s.manager_staff_id 
LEFT JOIN address a ON a.address_id = s.address_id GROUP BY s.manager_staff_id; 

-- 7g
SELECT s.store_id, ci.city, co.country FROM store s
LEFT JOIN address a ON a.address_id = s.address_id 
LEFT JOIN city ci ON ci.city_id = a.city_id 
LEFT JOIN country co ON co.country_id = ci.country_id; 

-- 7h
SELECT c.category_id, c.name AS 'category_name', SUM(p.amount) AS 'Gross Revenue' FROM category c 
LEFT JOIN film_category fc ON fc.category_id = c.category_id
LEFT JOIN inventory i ON i.film_id = fc.film_id
LEFT JOIN rental r ON r.inventory_id = i.inventory_id
LEFT JOIN payment p ON p.customer_id = r.customer_id 
GROUP BY c.category_id ORDER BY SUM(p.amount) DESC; 

-- 8a
CREATE TABLE top_five_genres AS 
SELECT c.category_id, c.name AS 'category_name', SUM(p.amount) AS 'Gross Revenue' FROM category c 
LEFT JOIN film_category fc ON fc.category_id = c.category_id
LEFT JOIN inventory i ON i.film_id = fc.film_id
LEFT JOIN rental r ON r.inventory_id = i.inventory_id
LEFT JOIN payment p ON p.customer_id = r.customer_id 
GROUP BY c.category_id ORDER BY SUM(p.amount) DESC; 

CREATE VIEW top_five_genres_view AS 
SELECT category_id, category_name, `Gross Revenue` FROM top_five_genres;

-- 8b
SELECT * FROM top_five_genres_view;

-- 8c
DROP VIEW top_five_genres_view;
