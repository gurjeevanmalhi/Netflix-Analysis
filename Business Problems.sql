-- Business Problems and Solutions

-- Notes

-- null, blanks, 0, or unknown in title, director, date_added, rating, duration_value, duration_type 

-- 1. Count the number of Movies vs TV Shows 

select
    type,
    count(type) as num_of_movies_and_shows
from netflix_titles
group by type;

-- 2. Find the most common rating for movies and TV shows  

-- 3. List all movies released in a specific year (e.g., 2020)

select title
from netflix_titles
where release_year = '2020';

-- 4. Find the top 5 countries with the most content on Netflix

select top 5
    c2.country_name,
    count(show_id) as content_amt
from show_country as c1
join countries as c2
    on c1.country_id = c2.country_id
group by c2.country_name
order by content_amt desc;

-- 5. Identify the longest movie

select top 1 title
from netflix_titles
where type = 'Movie'
order by duration_value desc;

-- 6. Find content added in the last 5 years 

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select distinct title
from netflix_titles
where director = 'Rajiv Chilaka';

-- 8. List all TV shows with more than 5 seasons

select title
from netflix_titles
where type = 'TV Show' and duration_value > 5;

-- 9. Count the number of content items in each genre  

select
    g.genre_name,
    count(show_id) as content_per_genre
from genre as g 
join show_genre as sg
    on g.genre_id = sg.genre_id
group by g.genre_name;

-- 10. Find the number of content released in India in each year. Return top 5 years with the highest amount of content release.

select top 5
    nt.release_year,
    count(nt.show_id) as releases_per_year
from netflix_titles as nt 
join show_country as sc 
    on nt.show_id = sc.show_id 
join countries as c2
    on sc.country_id = c2.country_id
where country_name = 'India'
group by
    nt.release_year,
    c2.country_name
order by releases_per_year desc;

-- 11. List all movies that are documentaries 

select
    nt.title
from netflix_titles as nt 
join show_genre as sg 
    on nt.show_id = sg.show_id
join genre as g 
    on sg.genre_id = g.genre_id
where genre_name = 'Documentaries';

-- 12. Find all content without a director

select title
from netflix_titles
where director = 'Unknown';

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select
    count(nt.show_id) as num_of_movies
from netflix_titles as nt 
join show_cast as sc 
    on nt.show_id = sc.show_id
join cast_list as c1
    on sc.cast_id = c1.cast_id
where type = 'Movie'
    and cast_member = 'Salman Khan'
    and nt.release_year >= year(getdate())-10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select top 10 cast_member
from(
    select
        cl.cast_member,
        count(sc.show_id) as num_of_shows
    from show_cast as sc
    join cast_list as cl 
        on sc.cast_id = cl.cast_id
    join show_country as sc2
        on sc.show_id = sc2.show_id
    join countries as c2
        on sc2.country_id = c2.country_id 
    where c2.country_name = 'India'
    group by
        sc.cast_id,
        cl.cast_member,
        c2.country_name
    ) as top_cast_subquery
order by num_of_shows;

from show_cast;
