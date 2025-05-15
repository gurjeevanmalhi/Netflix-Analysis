-- Handle Invalid, Inconsistent Data First
-- Handle Missing Data Second
-- Handle Duplicated Third
-- Column By Column

-- Created Staging Table
CREATE TABLE titles_staging (
	show_id VARCHAR(10),
	category VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(250),
	casts VARCHAR(800),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year VARCHAR(10),
	rating VARCHAR(20),
	duration VARCHAR(20),
	listed_in VARCHAR(100),
	description VARCHAR(300)
);

-- Identifying NULLs
select
	count(*) filter(where show_id is null) as show_id,
	count(*) filter(where category is null) as category,
	count(*) filter(where title is null) as title,
	count(*) filter(where director is null) as director, -- 2,634
	count(*) filter(where casts is null) as casts, -- 825
	count(*) filter(where country is null) as country, -- 831
	count(*) filter(where date_added is null) as date_added, - 10
	count(*) filter(where release_year is null) as release_year,
	count(*) filter(where rating is null) as rating, -- 4
	count(*) filter(where duration is null) as duration, -- 3 
	count(*) filter(where listed_in is null) as listed_in,
	count(*) filter(where description is null) as description
from titles_staging;

-- Detecting Invalid Data

select distinct director
from titles_staging
WHERE director SIMILAR TO '%[0-9!@#$%^&*()]%'
or director not similar to '%[A-Za-z\s.,-ÁÉÍÓÚáéíóú]%' 
and director is not null;
-- Observation: valid

select distinct category
from titles_staging;
-- Observation: 2 categories exist, both are valid.

select distinct title
from titles_staging
where title similar to '%[@#$%^*()]%';

-- Observation: movie titles can be dynamic and include special characters, digits, etc.
-- All titles appear valid, we will leave these in the dataset as is.

select distinct cast_member
from(
	select trim(regexp_split_to_table(casts,', ')) as cast_member
	from titles_staging
) as sub
where cast_member similar to '%[0-9!@#$%^&*()]%'
or cast_member not similar to '%[A-Za-z\s.,-ÁÉÍÓÚáéíóú]%';
-- Observation: valid

select distinct country
from(
	select trim(regexp_split_to_table(country,', ')) as country
	from titles_staging
) as sub
where country not similar to '%[A-Za-z]%';
-- Observation: valid

select
	show_id,
	date_added
from titles_staging
where date_added not similar to '[0-9]?[0-9]-[A-Za-z][a-z][A-Za-z]-[0-9]{2}'
order by 1 asc;
--Observation: valid. Will format all dates later in project.

select
	distinct release_year
from titles_staging
where release_year not similar to '[0-9]{4}';
-- Observation: valid

update titles_staging 
set duration = rating, -- updating duration column with correct values
	rating = null -- updating rating as null
where rating in (
		select rating -- this query finds 3 invalid values in rating, should be in duration column
		from titles_staging
		order by rating
		limit 3
);

select distinct trim(regexp_split_to_table(listed_in,', ')) as listed_in
from titles_staging
order by 1;
-- Observation: valid








/*-- Identifying Duplicates, No Exact Duplicates Found
select
	category,
	title,
	director,
	casts,
	country,
	date_added,
	release_year,
	rating,
	duration,
	listed_in,
	description
from titles_staging
group by
	category,
	title,
	director,
	casts,
	country,
	date_added,
	release_year,
	rating,
	duration,
	listed_in,
	description
having count(*) > 1;
*/

	














