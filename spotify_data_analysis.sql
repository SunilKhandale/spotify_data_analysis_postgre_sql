-- spotofy data analysis in pgsql
drop table if exists spotify;

create table spotify(Artist varchar(255), Track varchar(255),	Album varchar(255),
Album_type varchar(50), Danceability float, Energy float, Loudness float, Speechiness float,
Acousticness float, Instrumentalness float, Liveness float, Valence float, Tempo float,
Duration_min float, Title varchar(255), Channel varchar(255),	Views float, Likes bigint,
Comments bigint, Licensed boolean,	official_video boolean, Stream bigint,
EnergyLiveness float, most_playedon varchar(50)
);

select count(*) from spotify;
select * from spotify;

-- exploring the data EDA
/* 1. Data Exploration
Before diving into SQL, it’s important to understand the dataset thoroughly.
The dataset contains attributes such as:
Artist: The performer of the track.
Track: The name of the song.
Album: The album to which the track belongs.
Album_type: The type of album (e.g., single or album).
Various metrics such as danceability, energy, loudness, tempo, and more.
*/
select count(distinct artist) from spotify;
select count(distinct album) from spotify;
select count(distinct track) from spotify;
select distinct album_type from spotify;

select max(Duration_min) from spotify;
select min(Duration_min) from spotify;
-- the song cannot be of zero mins we need to deal with it 
select * from spotify 
where Duration_min = '0';

delete from spotify 
where Duration_min = '0';

select min(Duration_min) from spotify;

-- task 1 Retrieve the names of all tracks that have more than 1 billion streams.
select * from spotify
where stream > 1000000000;

---- task 2 List all albums along with their respective artists.

select distinct album from spotify;

select distinct album, artist from spotify order by 1;

-- task 3 Get the total number of comments for tracks where licensed = TRUE.

select distinct licensed from spotify;

select sum(comments) as total_cmt from spotify
where licensed = 'true';

-- task 4 Find all tracks that belong to the album type single.

select * from spotify where album_type ilike 'single';

-- task 5 Count the total number of tracks by each artist.

select * from spotify; -- distinct artist, count(track) as total_track_per_artist

select distinct artist, count(track) as total_track_per_artist from spotify
group by artist
order by 2 desc; 

-- Medium Level
-- task 6 Calculate the average danceability of tracks in each album.

select * from spotify; --distinct album, avg(danceability) as avg_danceability, track

select album, avg(danceability) as avg_danceability from spotify
group by 1
order by 2 desc;

-- task 7 Find the top 5 tracks with the highest energy values.

select * from spotify; -- where enegry, track
select distinct track, max(energy) as highest_energy from spotify
group by 1
order by 2 desc
limit 5;

-- task 8 List all tracks along with their views and likes where official_video = TRUE.

select * from spotify;
select track, sum(views) as total_views, sum(likes) as total_likes from spotify
where official_video = 'TRUE'
group by 1;

-- task 9 For each album, calculate the total views of all associated tracks.

select * from spotify; -- distinct album, sum(views) as total_views

select distinct album, track, sum(views) as total_views from spotify 
group by 1, 2;

-- task 10 Retrieve the track names that have been streamed on Spotify more than YouTube.

select * from spotify; -- most_playedon

select distinct most_playedon from spotify;

select * from 
(select track, -- coalesce is same as null in sql, to treat null values
coalesce(sum(case when most_playedon  = 'Youtube' then stream end), 0) as streamed_on_youtube,
coalesce(sum(case when most_playedon  = 'Spotify' then stream end), 0) as streamed_on_spotify
from spotify
group by 1
) as t1
where streamed_on_spotify > streamed_on_youtube
and streamed_on_youtube <> 0; -- <> is not equal to

-- Advanced Level

-- 11. Find the top 3 most-viewed tracks for each artist using window functions.
select * from spotify; -- track, artist, count(views) as total_views, 

with ranking_first
as
(
select artist, track, sum(views) as total_views,
dense_rank() over(partition by artist order by sum(views) desc) as rank from spotify
-- we use dense_rank bcz 1 artsit can have same number of views for his song 
group by 1, 2
order by artist, total_views desc
)
select * from ranking_first
where rank <= 3;

-- task 12. Write a query to find tracks where the liveness score is above the average.

select * from spotify; -- track, avg(liveness) as avg_liveness

select avg(liveness) from spotify; -- 0.19367208624708632

select track, artist, liveness
from spotify 
where liveness > (select avg(liveness) from spotify);

/* task 13. Use a WITH clause to calculate the difference between the highest and lowest
energy values for tracks in each album. */

select max(energy) from spotify;
select min(energy) from spotify;

with difference_in_energy as
(
select album, -- max(energy) as highest_energy, min(energy) as lowest_energy
max(energy) as highest_energy,
min(energy) as lowest_energy
from spotify
group by 1
)
select album, highest_energy - lowest_energy as energy_diff from difference_in_energy
order by 2 desc; 

-- alternate way
with diff_in_energy as 
(
select album, max(energy) as highest_energy,
min(energy) as min_energy from spotify 
group by 1
)
select album, highest_energy - min_energy as eng_diff from diff_in_energy
order by 2 desc;
