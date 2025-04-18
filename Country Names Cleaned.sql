-- View windows for clean countries

create view vw_clean_countries as 
select *
from(
    
    select
        show_id,
        trim(split_country.value) as clean_country
    from netflix_titles
    cross apply string_split(country,',') as split_country
    where country <> 'Unknown' -- query still contains blank values from split 

    ) as country_subquery

where clean_country <> ' '; -- filters out blank values

