## spotify_data_analysis_postgre_sql
![spotify_data](https://github.com/SunilKhandale/spotify_data_analysis_postgre_sql/blob/main/spotify_logo.png)
## Overview
This project involves analyzing a Spotify dataset with various attributes about tracks, albums, and artists using SQL. It covers an end-to-end process of normalizing a denormalized dataset, performing SQL queries of varying complexity (easy, medium, and advanced), and optimizing query performance. The primary goals of the project are to practice advanced SQL skills and generate valuable insights from the dataset.
## craeting the table and importing the record

```sql
create table spotify(Artist varchar(255), Track varchar(255),	Album varchar(255),
Album_type varchar(50), Danceability float, Energy float, Loudness float,
Speechiness float, Acousticness float, Instrumentalness float, Liveness float,
Valence float, Tempo float, Duration_min float, Title varchar(255),
Channel varchar(255), Views float, Likes bigint, Comments bigint, Licensed boolean,
official_video boolean, Stream bigint, EnergyLiveness float,
most_playedon varchar(50)
);

select * from spotify;
```
## exploring the data EDA
/* 1. Data Exploration */
-- Before diving into SQL, it’s important to understand the dataset thoroughly.
-- The dataset contains attributes such as:
-- Artist: The performer of the track.
select distinct artist from spotify; -- 2074 rows

##  Track: The name of the song.

```sql
select distinct track from spotify; -- 17715 rows
```

## -- Album: The album to which the track belongs.
```sql
select album, track from spotify
where track = 'Some';
```

### -- Album_type: The type of album (e.g., single or album).

```sql
select * from spotify
where album_type = 'album';

select * from spotify
where album_type = 'single';
```

## -- Various metrics such as danceability, energy, loudness, tempo, and more.

```sql
select count(danceability) as total_danceability, min(danceability) as min_danceability,
avg(danceability) as avg_danceability, max(danceability) as max_danceability from spotify;

select count(energy) as total_energy, min(energy) as min_energy,
avg(energy) as avg_energy, max(energy) as max_energy from spotify;

select count(loudness) as total_loudness, min(loudness) as min_loudness,
avg(loudness) as avg_loudness, max(loudness) as max_loudness from spotify;

select count(tempo) as total_tempo, min(tempo) as min_tempo,
avg(tempo) as avg_tempo, max(tempo) as max_tempo from spotify;
```

## -- task 1 Retrieve the names of all tracks that have more than 1 billion streams.

```sql
select * from spotify
where stream > 1000000000;
```

## -- task 2 List all albums along with their respective artists.

```sql
select distinct album, artist from spotify
order by 1;
```

## -- task 3 Get the total number of comments for tracks where licensed = TRUE.

```sql
select track, sum(comments) as total_comments from spotify
where licensed = 'true'
group by 1;
```

## -- task 4 Find all tracks that belong to the album type single.

```sql
select track from spotify
where album_type = 'single';
```

## -- task 5 Count the total number of tracks by each artist.

```sql
select artist, count(track) as total_tracks from spotify
group by 1
order by 2 desc;
```

## /*Medium Level*/
-- task 6 Calculate the average danceability of tracks in each album.

```sql
select album, track, avg(danceability) as avg_dance from spotify
group by 1, 2
order by avg_dance desc;
```

## -- task 7 Find the top 5 tracks with the highest energy values.

```sql
select track, max(energy) as high_energy
from spotify
group by 1
order by high_energy desc
limit 5;
```

## -- task 8 List all tracks along with their views and likes where official_video = TRUE.

```sql
select track, sum(views) as total_views, sum(likes) as total_likes from spotify 
where official_video = 'true'
group by 1;
```

## -- task 9 For each album, calculate the total views of all associated tracks.

```sql
select album, track, sum(views) as total_views from spotify
group by 1, 2;
```

## -- task 10 Retrieve the track names that have been streamed on Spotify more than YouTube.

```sql
-- coalesce is same as null in sql to treat null values
select * from (
select track,
coalesce(sum(case when most_playedon = 'Youtube' then stream end), 0) as stream_on_youtube,
coalesce(sum(case when most_playedon = 'Spotify' then stream end), 0) as stream_on_spotify
from spotify
group by 1) as t1
where stream_on_spotify > stream_on_youtube
and stream_on_youtube <> 0; -- <> means not equal to 
```

## -- Advanced Level
-- 11. Find the top 3 most-viewed tracks for each artist using window functions.

```sql
with most_viewd as(
select track, artist, sum(views) as total_views,
dense_rank() over(partition by artist order by sum(views) desc) as rank 
from spotify
group by 1, 2
order by artist, total_views desc
)
select * from most_viewd
where rank > 3;
```

## -- task 12. Write a query to find tracks where the liveness score is above the average.

```sql
select * from spotify; 
select avg(liveness) from spotify; -- 0.193672

select track, liveness
from spotify
where liveness > (select avg(liveness) from spotify);
```

## /* task 13. Use a WITH clause to calculate the difference between the highest and lowest
energy values for tracks in each album. */

```sql
select max(energy) from spotify;
select min(energy) from spotify;

with diff_energy as
(
select album, track,
max(energy) as high_energy,
min(energy) as min_energy
from spotify
group by 1, 2)
select album, high_energy - min_energy as energy_differnce from diff_energy
order by 2 desc;
```

/*Task 14 :-  Find tracks where the energy-to-liveness ratio is greater than 1.2. */
-- 1:2 means 1/2 = 0.5
```sql
select track, energy, liveness,
(energy::numeric / nullif(liveness, 0) * 100) as energy_liveness_ratio
from spotify -- 20592 records
where (energy::numeric / nullif(liveness, 0) * 100) > 0.5; -- 20587 records
```

## /* task 16 :- Calculate the cumulative sum of likes for tracks ordered by the
number of views, using window functions.*/
-- tracks, cumlative_sum(likes), order by views

```sql
with cumulative_sum_likes as(
select track, views, likes,
sum(likes) over(order by views)
as cumultivesum_likes
from spotify
where likes > 0 --469 records withviews = 0 so we take view > 0
group by track, likes, views)
select track, views, likes, cumultivesum_likes from cumulative_sum_likes;

select track from spotify where views = 0; --469 records withviews = 0
```
## /* indexing the artsist column :- indexing will return the o/p for query
faster than usual */
```sql
create index idx_artist on spotify(artist);
```
## report 

1. top 5 tracks with the highest energy values ie.
"Rain and Thunderstorm, Pt. 7"	1
"Rain and Thunderstorm, Pt. 33"	1
"Rain and Thunderstorm, Pt. 4"	1
"Rain and Thunderstorm, Pt. 6"	1
"Gentle Piano Melodies"	1
2. tracking names that have been streamed on Spotify more than YouTube.
there are 155 records where we can see tracks streamed more on spotify compared to youtube
3. top 3 most-viewed tracks for each artist
6808 records ranks <= 3 for each artist 
4. tracks where the liveness score is above the average
6364 such reords where liveness scre is above the average liveness score
5. difference between the highest and lowest energy values for tracks in each album
18680 such records 
6. query optimizationto enhance speed and efficency in database



