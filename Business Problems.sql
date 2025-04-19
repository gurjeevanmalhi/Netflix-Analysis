-- Business Problems and Solutions

-- 1. Count the number of Movies vs TV Shows 

select
    type,
    count(type) as num_of_movies_and_shows
from netflix_titles
group by type;

-- 2. Find the most common rating for movies and TV shows  
select
    type,
    rating
from

(
    select
        type,
        rating,
        count(*) as rating_count,
        rank() over(partition by type order by count(*)desc) as ranking
    from netflix_titles
    group by
        type,
        rating

) as t1 
where ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

select title
from netflix_titles
where
    type = 'Movie'
    and release_year = '2020';

-- 4. Find the top 5 countries with the most content on Netflix

select top 5
    c2.country_name,
    count(show_id) as total_content
from show_country as c1
join countries as c2
    on c1.country_id = c2.country_id
group by c2.country_name
order by total_content desc;

-- 5. Identify the longest movie

select top 1 title
from netflix_titles
where type = 'Movie'
order by duration_value desc;

-- 6. Find content added in the last 5 years 

select title, date_added
from netflix_titles
where date_added >= dateadd(year,-5,getdate());

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
    count(show_id) as total_content_per_genre
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
order by num_of_shows desc;

-- 15. Find the top 3 countries that have the highest number of TV Shows added to Netflix in the last 20 years.

select top 3 country_name
from

(
    select
        sc.country_id,
        c.country_name,
        count(sc.show_id) as num_of_movies
    from show_country as sc 
    join countries as c 
        on sc.country_id = c.country_id
    join netflix_titles as nt 
        on sc.show_id = nt.show_id
    where
        type = 'Movie'
        and date_added >= dateadd(year,-20,getdate())
    group by
        sc.country_id,
        c.country_name

) as t2
order by num_of_movies desc;

-- 16. List the top 5 directors with the most titles on Netflix, but exclude any null or empty values

select top 5
    director,
    count(show_id) as total_titles
from netflix_titles
where director <> 'Unknown' -- replaced null and empty values with 'Unknown' in cleaning stage
    and title <> 'Unknown' -- replaced null and empty values with 'Unknown' in cleaning stage
group by director
order by total_titles desc;

-- 17. Find the average duration (in minutes) of all Movies released after 2015. Ignore any non-Movie entries.

select
    type,
    avg(duration_value) as avg_duration
from netflix_titles
where type = 'Movie'
    and date_added > '2015-01-01' -- converting date into string 
group by type;

-- 18. For each year, count how many new titles were added to Netflix, and show only years where more than 100 titles were added. Order by year descending.

select
    year(date_added) as year_added,
    count(show_id) as total_titles
from netflix_titles
where date_added is not null 
group by year(date_added)
having count(show_id) > 100
order by total_titles desc;

-- 19. Find all titles that appear in more than one genre and group them by the number of genres.

select
    total_genres,
    count(distinct title) as titles_in_multiple_genres
from(

    select
        nt.title,
        count(distinct g.genre_name) as total_genres
    from show_genre as sg 
    join netflix_titles as nt
        on sg.show_id = nt.show_id
    join genre as g 
        on sg.genre_id = g.genre_id
    group by nt.title
    having count(distinct g.genre_name) > 1

    ) as t3
group by total_genres
order by total_genres desc;

