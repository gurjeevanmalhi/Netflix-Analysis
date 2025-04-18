-- Normalizing genres and creating views
create view vw_clean_genres as 
select
    show_id,
    case 
        when trim(split_genre.value) like '%Crime%' then 'Crime'
        when trim(split_genre.value) like '%Drama%' then 'Drama'
        when trim(split_genre.value) like '%International%' then 'International'
        when trim(split_genre.value) like '%Korean%' then 'International'
        when trim(split_genre.value) like '%Spanish%' then 'International'
        when trim(split_genre.value) like '%British%' then 'International'
        when trim(split_genre.value) like '%Roman%' then 'Romance'
        when trim(split_genre.value) like '%Comed%' then 'Comedy'
        when trim(split_genre.value) like '%Docu%' then 'Documentaries'
        when trim(split_genre.value) like '%Horror%' then 'Horror'
        when trim(split_genre.value) like '%Thrill%' then 'Thrillers'
        when trim(split_genre.value) like '%Myster%' then 'Mystery'
        when trim(split_genre.value) like '%Action & Adventure%' then 'Action'
        when trim(split_genre.value) like '%Music%' then 'Musicals'
        when trim(split_genre.value) like '%Classic%' then 'Classic'
        when trim(split_genre.value) like '%Cult%' then 'Classic'
        when trim(split_genre.value) like '%Kids%' then 'Children & Family'
        when trim(split_genre.value) like '%Children%' then 'Children & Family'
        when trim(split_genre.value) like '%Anime%' then 'Anime'
        when trim(split_genre.value) like '%Independ%' then 'Independent'
        when trim(split_genre.value) like '%Teen%' then 'Teen'
        when trim(split_genre.value) like '%Sci-Fi%' then 'Sci-Fi'
        when trim(split_genre.value) like '%Science%' then 'Science & Nature'
        when trim(split_genre.value) like '%Faith%' then 'Religion'
        when trim(split_genre.value) like '%Reality%' then 'Reality'
        when trim(split_genre.value) like '%Sport%' then 'Sports'
        when trim(split_genre.value) like '%LGBTQ%' then 'LGBTQ'
        else trim(split_genre.value)
    end as clean_genre
from netflix_titles
cross apply string_split(listed_in,',') as split_genre;