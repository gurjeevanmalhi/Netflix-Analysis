-- Data Cleaning and Manipulation

-- 1. Replacing all NULL and blank values with 'Unknown' (director, casts, country, date_added, rating, duration)

update netflix_titles
set 
    director = case
        when director is null or LTRIM(RTRIM(director)) = ' ' then 'Unknown'
        else director
        end,
    casts = case 
        when casts is null or LTRIM(RTRIM(casts)) = ' ' then 'Unknown'
        else casts 
        end,
    country = case 
        when country is null or LTRIM(RTRIM(country)) = ' ' then 'Unknown'
        else country
        end,
    rating = case 
        when rating is null or LTRIM(RTRIM(rating)) = ' ' then 'Unknown'
        else rating 
        end,
    duration = case 
        when duration is null or LTRIM(RTRIM(duration)) = ' ' then 'Unknown'
        else duration
        end;

-- 2. Create table for casts

create table casts(
    show_id NVARCHAR(10),
    cast_member NVARCHAR(100)
);
-- 3. Insert into for casts

insert into casts (show_id, cast_member)
select 
    show_id,
    trim(value) as cast_member
from netflix_titles
cross apply string_split(casts, ',')
where casts <> 'Unknown';

-- 4. Create table for country

create table countries(
    show_id NVARCHAR(10),
    country NVARCHAR(50)
);

-- 5. Insert into for country

insert into countries(show_id, country)
select
    show_id,
    trim(value) as country 
from netflix_titles
cross apply string_split(country, ',')
where country <> 'Unknown';

-- 6. Create table for genres

create table genres(
    show_id NVARCHAR(10),
    genre NVARCHAR(50)
);

-- 7. Insert into genres

insert into genres(show_id,genre)
select 
    show_id,
    trim(value) as genre
from netflix_titles
cross apply string_split(listed_in, ',')
where listed_in is not null 
    or listed_in <> 'Unknown';

-- 8. Normalize genres

update genres
set genre = 
    case 
        when genre like '%Crime%' then 'Crime'
        when genre like '%Drama%' then 'Drama'
        when genre like '%International%' then 'International'
        when genre like '%Korean%' then 'International'
        when genre like '%Spanish%' then 'International'
        when genre like '%British%' then 'International'
        when genre like '%Roman%' then 'Romance'
        when genre like '%Comed%' then 'Comedy'
        when genre like '%Docu%' then 'Documentaries'
        when genre like '%Horror%' then 'Horror'
        when genre like '%Thrill%' then 'Thrillers'
        when genre like '%Myster%' then 'Mystery'
        when genre like '%Action & Adventure%' then 'Action'
        when genre like '%Music%' then 'Musicals'
        when genre like '%Classic%' then 'Classic'
        when genre like '%Cult%' then 'Classic'
        when genre like '%Kids%' then 'Children & Family'
        when genre like '%Children%' then 'Children & Family'
        when genre like '%Anime%' then 'Anime'
        when genre like '%Independ%' then 'Independent'
        when genre like '%Teen%' then 'Teen'
        when genre like '%Sci-Fi%' then 'Sci-Fi'
        when genre like '%Science%' then 'Science & Nature'
        when genre like '%Faith%' then 'Religion'
        when genre like '%Reality%' then 'Reality'
        when genre like '%Sport%' then 'Sports'
        when genre like '%LGBTQ%' then 'LGBTQ'
        else genre
    end;

-- 9. Normalize duration column

alter table netflix_titles -- adding column for value of duration of unit of measurement (minutes or season)
add
    duration_value int,
    duration_unit NVARCHAR(10);

update netflix_titles -- extracting from duration column into new columns
set
    duration_value = case 
        when CHARINDEX(' ',duration) > 0
        then try_cast(left(duration, CHARINDEX(' ',duration)-1)as int)
        else null 
    end,
    duration_unit = case 
        when CHARINDEX(' ',duration) > 0
        then LTRIM(RIGHT(duration,len(duration)-CHARINDEX(' ',duration)))
        else null
    end;

update netflix_titles
set
    duration_unit = case
        when duration_unit like '%Seas%' then 'Season'
        else duration_unit
        end;

-- 10. Drop columns no longer needed
select * from netflix_titles;
alter table netflix_titles
drop column
    casts,
    country,
    duration;

alter table netflix_titles
drop column 
    listed_in;
