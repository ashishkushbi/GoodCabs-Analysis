use `targets_db`;

select * from city_target_passenger_rating;
select * from monthly_target_new_passengers;
select * from monthly_target_trips;

select city_id, month(month), (total_target_trips) as target_trip 
from monthly_target_trips
group by 1,2,3;

round(((total_trips*100)/sum(total_trips) over()),2) as pct_contribution,


----------------------------------------------------------
-- Q 1. City level fare and trip summary report.
----------------------------------------------------------

with cte as (
select c.city_name as city_name, 
       count(distinct(trip_id)) as total_trips, 
       round((sum(fare_amount)/sum(distance_travelled_km)),2) as avg_fare_per_km,
       round((sum(fare_amount)/count(distinct(trip_id))),2) as avg_fare_per_trip
from  fact_trips as f
join dim_city as c on c.city_id = f.city_id
group by c.city_name
) 
select  city_name, 
		total_trips, 
		avg_fare_per_km,
		avg_fare_per_trip,
		round(((total_trips*100)/(select sum(total_trips) from cte)),2) as pct_contribution_to_total_trips
		from cte
    group by city_name
    order by pct_contribution_to_total_trips desc;
    

------------------------------------------------------
-- Q.02 Monthly City Level Trips Target Performance Report.
-----------------------------------------------------
select city_name,  performance_status, count(*) from (
select    (tm.month)  as date, 
          monthname(tm.month) as month_name,
		  city_name,
          ft.actual_trips,
		  total_target_trips,
          (case when ft.actual_trips > total_target_trips then 'above_target' else 'below_target' end ) as performance_status,
          round(( ( ft.actual_trips - total_target_trips) *100 /  ft.actual_trips ),2) as difference
from targets_db.monthly_target_trips as tm
join 
trips_db.dim_city as tc
on tm.city_id=tc.city_id
join
	( select city_id, month(month) as months, count(distinct(trip_id)) as actual_trips 
    from trips_db.fact_trips group by 1,2  )as ft
on tm.city_id = ft.city_id and ft.months = month(tm.month)
) as ss
group by 1,2;
-------------------------------------------------------------

select city_name, sum( case when performance_status = 'above_target' then 1 else 0 end) as above_times , 
                  sum( case when performance_status = 'below_target' then 1 else 0 end) as below_times 
from (
select    (tm.month)  as date, 
          monthname(tm.month) as month_name,
		  city_name,
          ft.actual_trips,
		  total_target_trips,
          (case when ft.actual_trips > total_target_trips then 'above_target' else 'below_target' end ) as performance_status,
          round(( ( ft.actual_trips - total_target_trips) *100 /  ft.actual_trips ),2) as difference
from targets_db.monthly_target_trips as tm
join 
trips_db.dim_city as tc
on tm.city_id=tc.city_id
join
	( select city_id, month(month) as months, count(distinct(trip_id)) as actual_trips 
    from trips_db.fact_trips group by 1,2  )as ft
on tm.city_id = ft.city_id and ft.months = month(tm.month)
) as ss
group by 1

-------------------------------------------------------------


with cte as ( select city_id, month(month) as months, count(distinct(trip_id)) as total_trips 
             from fact_trips
             group by 1,2  )
            
select    month(tm.month) as months, 
		  tm.city_id,
          city_name,
          total_trips,
		  sum(total_target_trips) as target_trips
from cte as ct
join
targets_db.monthly_target_trips as tm
on ct.city_id=tm.city_id
join trips_db.dim_city as cty
on cty.city_id=tm.city_id
group by 1,2,3,4;



---------------------------------------------------------------------------
-- Q.3 City level repeat passenger trip report.
---------------------------------------------------------------------------
with cte as (
				select city_id, 
					   sum(case when trip_count = "2-Trips" then (repeat_passenger_count) else 0 end) as trip_2,
					   sum(case when trip_count = "3-Trips" then (repeat_passenger_count) else 0 end) as trip_3,
					   sum(case when trip_count = "4-Trips" then (repeat_passenger_count) else 0 end) as trip_4,
					   sum(case when trip_count = "5-Trips" then (repeat_passenger_count) else 0 end) as trip_5,
					   sum(case when trip_count = "6-Trips" then (repeat_passenger_count) else 0 end) as trip_6,
					   sum(case when trip_count = "7-Trips" then (repeat_passenger_count) else 0 end) as trip_7,
					   sum(case when trip_count = "8-Trips" then (repeat_passenger_count) else 0 end) as trip_8,
					   sum(case when trip_count = "9-Trips" then (repeat_passenger_count) else 0 end) as trip_9,
					   sum(case when trip_count = "10-Trips" then (repeat_passenger_count) else 0 end) as trip_10,
					   sum(repeat_passenger_count) as total 
					   from dim_repeat_trip_distribution
					   group by 1
  )     
       
       select city_id,
              round((trip_2/total)*100,2) as trip2,
              round((trip_3/total)*100,2) as trip3,
              round((trip_4/total)*100,2) as trip4,
              round((trip_5/total)*100,2) as trip5,
              round((trip_6/total)*100,2) as trip6,
              round((trip_7/total)*100,2) as trip7,
              round((trip_8/total)*100,2) as trip8,
              round((trip_9/total)*100,2) as trip9,
              round((trip_10/total)*100,2) as trip10
       from cte;
       
---------------------------------------------------------------------------
-- Q.3 City level repeat passenger trip countribution in percentage.
---------------------------------------------------------------------------

select city_name, 
       round((sum(case when trip_count = "2-Trips" then (repeat_passenger_count) else 0 end)*100/sum(repeat_passenger_count)),2) as trip_2,
	   round((sum(case when trip_count = "3-Trips" then (repeat_passenger_count) else 0 end)*100/sum(repeat_passenger_count)),2) as trip_3,
	   round((sum(case when trip_count = "4-Trips" then (repeat_passenger_count) else 0 end)*100/sum(repeat_passenger_count)),2) as trip_4,
       round((sum(case when trip_count = "5-Trips" then (repeat_passenger_count) else 0 end)*100/sum(repeat_passenger_count)),2) as trip_5,
       round((sum(case when trip_count = "6-Trips" then (repeat_passenger_count) else 0 end)*100/sum(repeat_passenger_count)),2) as trip_6,
       round((sum(case when trip_count = "7-Trips" then (repeat_passenger_count) else 0 end)*100/sum(repeat_passenger_count)),2) as trip_7,
       round((sum(case when trip_count = "8-Trips" then (repeat_passenger_count) else 0 end)*100/sum(repeat_passenger_count)),2) as trip_8,
       round((sum(case when trip_count = "9-Trips" then (repeat_passenger_count) else 0 end)*100/sum(repeat_passenger_count)),2) as trip_9,
       round((sum(case when trip_count = "10-Trips" then (repeat_passenger_count) else 0 end)*100/sum(repeat_passenger_count)),2) as trip_10
       from dim_repeat_trip_distribution as rt
       join dim_city as ct
       on rt.city_id = ct.city_id
       group by 1;
       
  select * from monthly_target_new_passengers;
select * from fact_passenger_summary;
     
---------------------------------------------------------------------------
-- Q.04 Identify cities with Highest and Lowest Total New Passenger.
---------------------------------------------------------------------------  
    ---------------  Top 3 Cities ----------------   
select city_name, sum(tp.new_passengers) as total_new_passengers,
row_number() over ( order by sum(tp.new_passengers) desc) as top_cities
from fact_passenger_summary as tp
join dim_city as ct
on tp.city_id = ct.city_id
group by 1
limit 3;
    ---------------  Bottom 3 Cities ----------------   
select city_name, sum(tp.new_passengers) as total_new_passengers,
row_number() over ( order by sum(tp.new_passengers) asc) as bottom_cities
from fact_passenger_summary as tp
join dim_city as ct
on tp.city_id = ct.city_id
group by 1
limit 3;


-------------------------------------------------------------
-- Q.05 Identify month with highest Revenue for each city
-------------------------------------------------------------

select * from fact_passenger_summary;
select * from fact_trips;

select city_id, 
       date_format(month,'%M') AS month_name, 
	   sum(fare_amount) as revenue,
       dense_rank() over(partition by city_id order by sum(fare_amount) desc) as ranking
    from fact_trips
group by 1,2;


select a1.city_name,
       a1.month_name as Highest_Revenue_Month,
       a1.revenue,
	   round((a1.revenue*100/a2.total_revenue),2) as Countribution_percentage
       from
(select date_format( month, '%M' )as month_name,
      ft.city_id as city_ids,
      city_name,
	  sum(fare_amount) as revenue,
      rank() over(partition by city_name order by sum(fare_amount) desc )as ranking
      from fact_trips as ft
      join dim_city as ct
      on ft.city_id = ct.city_id
      group by 1 ,2,3
) as a1
join 
( select city_id, sum(fare_amount) as total_revenue from fact_trips group by 1 ) as a2
on a1.city_ids = a2.city_id
where a1.ranking = 1;

select city_id, sum(fare_amount) as total_revenue from fact_trips group by 1;
-------------------------------------------------------------

select a1.city_name,
       a1.month_name,
       a1.revenue,
       a1.ranking,
       a2.total_revenue,
	   round((a1.revenue*100/a2.total_revenue),2) as Countribution_percentage
       from
(select date_format( month, '%M' )as month_name,
      ft.city_id as city_ids,
      city_name,
	  sum(fare_amount) as revenue,
      rank() over(partition by city_name order by sum(fare_amount) desc )as ranking
      from fact_trips as ft
      join dim_city as ct
      on ft.city_id = ct.city_id
      group by 1 ,2,3
) as a1
join 
( select city_id, sum(fare_amount) as total_revenue from fact_trips group by 1 ) as a2
on a1.city_ids = a2.city_id;


-------------------------------------------------------------
-- Q.06 Repeat Passanger rate analysis.
-------------------------------------------------------------

select * from fact_passenger_summary;
select * from dim_repeat_trip_distribution;

with cte as	     ( select ps.city_id,
						   city_name,
						   date_format(month,'%M') as Month_name,
						   sum(total_passengers) as total_passengers,
						   sum(new_passengers) as total_new_passengers,
						   sum(repeat_passengers) as repeat_passengers,
						   round(sum(repeat_passengers)*100/sum(total_passengers),2) as Monthly_repeat_passenger_rate,
						   city_wide_repeat_passenger_rate
					from fact_passenger_summary as ps
					join dim_city as ct
					on ps.city_id = ct.city_id
					join 
					(
					select city_id, round(sum(repeat_passengers)*100/sum(total_passengers),2) as city_wide_repeat_passenger_rate
					from fact_passenger_summary
					group by 1
					) as cw
					on ps.city_id = cw.city_id
					group by 1,2,3 
					order by 1
                 )     
select city_name, Month_name, total_passengers, 
       repeat_passengers, Monthly_repeat_passenger_rate, city_wide_repeat_passenger_rate          
from cte;


 
 select city_name,
       date_format(month,'%M') as Month_name,
       sum(total_passengers) as total_passengers,
       sum(new_passengers) as total_new_passengers,
       round(sum(repeat_passengers)*100/sum(total_passengers),2) as Monthly_repeat_passenger_rate,
       (
			select  round(sum(repeat_passengers)*100/sum(total_passengers),2) 
			from fact_passenger_summary
			where ps.city_id = city_id
			group by city_id
       ) as city_wide_repeat_passenger_rate
      
from fact_passenger_summary as ps
join dim_city as ct
on ps.city_id = ct.city_id

group by 1,2      
order by 1;

select * from city_target_passenger_rating
select * from fact_trips


-------------------------------------------------------------
-- Q.07 Mark the cities who have greater avg (rating) then the targeted avg rating for passenger.
-------------------------------------------------------------

with cte as (
				select c.city_name as city_names,
					   f.city_id, 
					   round(avg(passenger_rating),2) as avg_passenger_ratings,
					   ct.target_avg_passenger_rating as target_avg_passenger_ratings ,
					   (
					   case when avg(passenger_rating)> ct.target_avg_passenger_rating then 'Above_target' else 'Below_target' end
					   ) as city_rating_status
					   from trips_db.fact_trips as f
					   join trips_db.dim_city as c
					   on f.city_id = c.city_id
					   join targets_db.city_target_passenger_rating as ct
					   on ct.city_id = f.city_id
					group by 1,2
			)
            
            select city_names,
                   avg_passenger_ratings,
                   target_avg_passenger_ratings,
                   city_rating_status
			from cte;








