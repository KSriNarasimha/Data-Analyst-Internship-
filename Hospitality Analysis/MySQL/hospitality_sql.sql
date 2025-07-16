create database hospitality;
use hospitality;
select count(*) from fact_bookings;

select * from dim_date,dim_hotels,dim_rooms,fact_aggregated_bookings,fact_bookings;

select * from dim_date;
select * from dim_hotels;
select * from dim_rooms;
select * from fact_aggregated_bookings;
select * from fact_bookings;

-- types of booking status = no_show, cancelled, checked_out
select distinct booking_status from fact_bookings;

-- cancelled
select count(*) from fact_bookings
where booking_status = "cancelled";

-- cancelled rate
select 
		round(
        100.0 *	 sum(case when booking_status = 'cancelled' then 1 else 0 end)
								/
			count(*) ,
            2
            ) as canceled_rate_percentage
from fact_bookings;

-- no show
select count(*) from fact_bookings
where booking_status = "no show";

-- no show rate 
select 
		round(
        100.0 *	 sum(case when booking_status = 'no show' then 1 else 0 end)
								/
			count(*) ,
            2
            ) as canceled_rate_percentage
from fact_bookings;

-- Checked out
select count(*) from fact_bookings
where booking_status = "checked out";

-- checked out rate 
select 
		round(
        100.0 *	 sum(case when booking_status = 'checked out' then 1 else 0 end)
								/
			count(*) ,
            2
            ) as canceled_rate_percentage
from fact_bookings;

-- occupancy %
select
	round(
			100.0 * sum(successful_bookings) / sum(capacity) ,
            2
		) as occupancy_percentage
from fact_aggregated_bookings;

-- Total_successful_bookings
select count(no_guests) 
from fact_bookings 
where booking_status = "checked out";

-- Total_bookings
select sum(successful_bookings) as Total_successful_bookings
from fact_aggregated_bookings;

-- Total successful bookings percentage
WITH successful_bookings_cte AS (
    SELECT 
        COUNT(*) AS successful_bookings
    FROM fact_bookings 
    WHERE booking_status = 'checked out'
),
total_bookings_cte AS (
    SELECT 
        SUM(successful_bookings) AS total_bookings
    FROM fact_aggregated_bookings
)
SELECT 
    ROUND(
        100.0 * s.successful_bookings / t.total_bookings,
        2
    ) AS successful_booking_percentage
FROM successful_bookings_cte s
JOIN total_bookings_cte t ON 1=1;

-- revenue Earned
select concat(
				round( sum(revenue_realized) / 10000000 , 2) , "CR"
			 ) as Revenue_Earned
from fact_bookings;

-- class wise revenue earned
SELECT 
    dr.room_class,
    ROUND(SUM(fb.revenue_realized), 2) AS total_revenue
FROM fact_bookings fb
JOIN dim_rooms dr
    ON fb.room_category = dr.room_id
GROUP BY dr.room_class
ORDER BY total_revenue DESC;


