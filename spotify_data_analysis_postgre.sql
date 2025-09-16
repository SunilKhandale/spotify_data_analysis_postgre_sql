-- spotofy data analysis in pgsql
create table spotify(Artist varchar(255), Track varchar(255),	Album varchar(255),
Album_type varchar(50), Danceability float, Energy float, Loudness float,
Speechiness float, Acousticness float, Instrumentalness float, Liveness float,
Valence float, Tempo float, Duration_min float, Title varchar(255),
Channel varchar(255), Views float, Likes bigint, Comments bigint, Licensed boolean,
official_video boolean, Stream bigint, EnergyLiveness float,
most_playedon varchar(50)
);

select * from spotify;

-- exploring the data EDA
/* 1. Data Exploration */
-- Before diving into SQL, it’s important to understand the dataset thoroughly.
-- The dataset contains attributes such as:
-- Artist: The performer of the track.
select distinct artist from spotify; -- 2074 rows

-- Track: The name of the song.

select distinct track from spotify; -- 17715 rows

-- Album: The album to which the track belongs.

select album, track from spotify
where track = 'Some';

-- Album_type: The type of album (e.g., single or album).

select * from spotify
where album_type = 'album';

select * from spotify
where album_type = 'single';

-- Various metrics such as danceability, energy, loudness, tempo, and more.

select count(danceability) as total_danceability, min(danceability) as min_danceability,
avg(danceability) as avg_danceability, max(danceability) as max_danceability from spotify;

select count(energy) as total_energy, min(energy) as min_energy,
avg(energy) as avg_energy, max(energy) as max_energy from spotify;

select count(loudness) as total_loudness, min(loudness) as min_loudness,
avg(loudness) as avg_loudness, max(loudness) as max_loudness from spotify;

select count(tempo) as total_tempo, min(tempo) as min_tempo,
avg(tempo) as avg_tempo, max(tempo) as max_tempo from spotify;

-- task 1 Retrieve the names of all tracks that have more than 1 billion streams.

select * from spotify
where stream > 1000000000;

-- task 2 List all albums along with their respective artists.

select distinct album, artist from spotify
order by 1;

-- task 3 Get the total number of comments for tracks where licensed = TRUE.

select track, sum(comments) as total_comments from spotify
where licensed = 'true'
group by 1;

-- task 4 Find all tracks that belong to the album type single.

select track from spotify
where album_type = 'single';

-- task 5 Count the total number of tracks by each artist.

select artist, count(track) as total_tracks from spotify
group by 1
order by 2 desc;

/*Medium Level*/
-- task 6 Calculate the average danceability of tracks in each album.

select album, track, avg(danceability) as avg_dance from spotify
group by 1, 2
order by avg_dance desc;

-- task 7 Find the top 5 tracks with the highest energy values.

select track, max(energy) as high_energy
from spotify
group by 1
order by high_energy desc
limit 5;

-- task 8 List all tracks along with their views and likes where official_video = TRUE.

select track, sum(views) as total_views, sum(likes) as total_likes from spotify 
where official_video = 'true'
group by 1;

-- task 9 For each album, calculate the total views of all associated tracks.

select album, track, sum(views) as total_views from spotify
group by 1, 2;

-- task 10 Retrieve the track names that have been streamed on Spotify more than YouTube.
-- track, most_playedon, stream

-- coalesce is same as null in sql to treat null values
select * from (
select track,
coalesce(sum(case when most_playedon = 'Youtube' then stream end), 0) as stream_on_youtube,
coalesce(sum(case when most_playedon = 'Spotify' then stream end), 0) as stream_on_spotify
from spotify
group by 1) as t1
where stream_on_spotify > stream_on_youtube
and stream_on_youtube <> 0; -- <> means not equal to 

-- Advanced Level
-- 11. Find the top 3 most-viewed tracks for each artist using window functions.

with most_viewd as(
select track, artist, sum(views) as total_views,
dense_rank() over(partition by artist order by sum(views) desc) as rank 
from spotify
group by 1, 2
order by artist, total_views desc
)
select * from most_viewd
where rank > 3;

-- task 12. Write a query to find tracks where the liveness score is above the average.

-- track, avg(liveness) as avg_liveness 
select * from spotify; 

select avg(liveness) from spotify; -- 0.193672

select track, liveness
from spotify
where liveness > (select avg(liveness) from spotify);

/* task 13. Use a WITH clause to calculate the difference between the highest and lowest
energy values for tracks in each album. */

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



