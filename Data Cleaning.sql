-- Data Cleaning

-- Replacing NULL and blanks with "Unknown"

update netflix_titles
set 
    director = case 
        when director is null or trim(director) = ' ' then 'Unknown'
        else director
        end,
    casts = case 
        when casts is null or trim(casts)= ' ' then 'Unknown'
        else casts 
        end,
    country = case 
        when country is null or trim(country) = ' ' then 'Unknown'
        else country
        end,
    rating = case 
        when rating is null or trim(rating) = ' ' then 'Unknown'
        else rating
        end,
    duration = case 
        when duration is null or trim(duration) = ' ' then 'Unknown'
        else duration
        end,
    listed_in = case 
        when listed_in is null or trim(listed_in) = ' ' then 'Unknown'
        else listed_in
        end,
    title_description = case 
        when title_description is null or trim(title_description) = ' ' then 'Unknown'
        else title_description
        end;
    

-- Normalization

-- Creating casts table

create table cast_list(
    cast_id int primary key identity(1,1),
    cast_member nvarchar(255)
);

-- Insert into cast table

insert into cast_list(cast_member)
select distinct trim(split_cast.value)
from netflix_titles
cross apply string_split(casts,',') as split_cast
where casts <> 'Unknown';

-- Creating junction table (show-cast relationship)

create table show_cast(
    show_id nvarchar(10),
    cast_id int,
    foreign key (show_id) references netflix_titles(show_id),
    foreign key (cast_id) references cast_list(cast_id)
);

-- Insert into show_cast

insert into show_cast(show_id,cast_id)
select
    nt.show_id,
    c.cast_id
from netflix_titles as nt
cross apply string_split(casts,',') as cast_member_split
join cast_list as c 
    on trim(cast_member_split.value) = c.cast_member;

-- Creating countries table table

create table countries(
    country_id int primary key identity (1,1),
    country_name varchar(50)
);


-- Insert into countries table (see view windows query for cleaning syntax)

insert into countries(country_name)
select distinct clean_country
from vw_clean_countries;

-- Creating junction table (show_country relationship)

create table show_country(
    show_id nvarchar(10),
    country_id int,
    foreign key (show_id) references netflix_titles(show_id),
    foreign key (country_id) references countries(country_id)
);

-- Insert into show_country

insert into show_country(show_id, country_id)
select
    vwc.show_id,
    c2.country_id
from vw_clean_countries as vwc
join countries as c2 
    on vwc.clean_country = c2.country_name;

-- Creating genres table

create table genre(
    genre_id int primary key identity (1,1),
    genre_name nvarchar(50)
);
-- Insert into genre table

insert into genre(genre_name)
select
    distinct clean_genre
from vw_clean_genres;

-- Creating junction table (show-genre relationship)

create table show_genre(
    show_id nvarchar(10),
    genre_id int
    foreign key (show_id) references netflix_titles (show_id),
    foreign key (genre_id) references genre(genre_id)
);

-- Inserting into show_genre (see view windows query for cleaning syntax)

insert into show_genre(show_id, genre_id)
select
    vw.show_id,
    g.genre_id
from vw_clean_genres as vw
join genre as g 
    on vw.clean_genre = g.genre_name;

---- Creating columns to normalize duration

alter table netflix_titles
add
    duration_value int,
    duration_type nvarchar(20);

-- Extract from duration and update into duration value and duration type

update netflix_titles
set 
    duration_value = left(duration,CHARINDEX(' ',duration, -1)), -- finds position before space and returns all string to the left
    duration_type =right(duration,LEN(duration) - CHARINDEX(' ',duration)); -- subtracts position of space from total string length and returns all string to the right

-- Normalizing strings for duration type

update netflix_titles
set 
    duration_type = case 
        when duration_type like '%min%' then 'minute'
        when duration_type like '%seas%' then 'season'
        else duration_type
        end;

-- Removing columns from netflix table

alter table netflix_titles
drop column 
    casts,
    country,
    duration,
    listed_in;








