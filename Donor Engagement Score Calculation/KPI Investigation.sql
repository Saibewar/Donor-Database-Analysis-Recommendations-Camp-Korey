-- Table Descriptions

/*
   Transf_gift_data     	Cleaned gift dataset using python 
   donor_duplicate.         Donor table with duplicate IDs 
   Removed_dup_donor	    Donor table after removing duplicate IDs 
*/

-- GIFT FREQUENCY
select 
	year(Gf_Date) as Year
    ,count(distinct Gf_CnBio_ID) as NumDonors
    ,count(distinct Gf_Gift_ID) as NumGifts
    ,count(distinct Gf_Gift_ID)/count(distinct Gf_CnBio_ID) as GiftsPerDonor
from
	Transf_gift_data -- ck.gifts
group by
	year(Gf_Date)
;

-- MATCHING GIFT RATE
select 
	count(*) as TotalGifts
    ,sum(case when d.CnBio_Matching_Gift_Flag = 'Yes' then 1 else 0 end) as MatchedGifts
    ,(sum(case when d.CnBio_Matching_Gift_Flag = 'Yes' then 1 else 0 end)/count(*))*100 as PctMatched
from 
	Transf_gift_data g
    left join Removed_dup_donor1 d
		on g.Gf_CnBio_ID = d.CnBio_ID
;

-- ONE TIME VS. REPEAT DONORS (INDIVIDUAL ONLY)
drop table if exists GiftCount;
create temporary table GiftCount as
select 
	d.CnBio_ID
    ,case 
		when count(distinct g.Gf_Gift_ID) = 1 then 'One Time Donor'
        when count(distinct g.Gf_Gift_ID) = 0 then 'Never Donated'
        when count(distinct g.Gf_Gift_ID) > 1 then 'Multiple Donations'
        end as GiftCountCategory
	,sum(g.Gf_Amount) as TotalDonationAmt
from 
	Removed_dup_donor d 
    left join Transf_gift_data g
		on g.Gf_CnBio_ID = d.CnBio_ID
where
	d.CnBio_Constit_Code = 'Individual'
group by
	d.CnBio_ID
;

-- How many donors are one-time vs. repeated? How much on average do they give?
select
	GiftCountCategory
    ,count(distinct CnBio_ID) as NumberOfDonors
    ,round(avg(TotalDonationAmt),2) as AverageDonationAmt
from
	GiftCount gc

where
	GiftCountCategory <> 'Never Donated'
group by GiftCountCategory
;

-- Are there noticible differences between one-time and repeated donors?
select
	gc.GiftCountCategory
    ,count(distinct gc.CnBio_ID) as NumberOfDonors
    ,round(avg(gc.TotalDonationAmt),2) as AverageDonationAmt
    ,(sum(case when d.CnAdrPrf_State = 'WA' then 1 else 0 end)/count(distinct gc.CnBio_ID))*100 as PctInWA
from 
	GiftCount gc
    left join Removed_dup_donor d
		on gc.CnBio_ID = d.CnBio_ID
where
	gc.GiftCountCategory <> 'Never Donated'
group by
	GiftCountCategory
;

-- COMPARING STATISTICS ACROSS CITIES (individual only)
select 
	d.CnAdrPrf_City as City
    ,count(distinct d.CnBio_ID) as NumberOfDonors
    ,count(distinct g.Gf_Gift_ID) as NumberOfGifts
    ,round(sum(g.Gf_Amount),2) as TotalGiftAmount
    ,round(avg(g.Gf_Amount),2) as AverageGiftAmount
from 
	Removed_dup_donor d
    left join Transf_gift_data g
		on g.Gf_CnBio_ID = d.CnBio_ID
where 
	d.CnAdrPrf_City <> ''
    and d.CnBio_Constit_Code = 'Individual'
group by
	d.CnAdrPrf_City
order by
	count(distinct d.CnBio_ID) desc
;

-- Get the frequency of donations by each donor and their total amount donated. Then sort it in descending order based on the total amount donated. Amongst these find the donors with missing contact information

SELECT 
	d.CnBio_Name, 
    g.Gf_CnBio_ID, 
    COUNT(g.Gf_CnBio_ID) AS Donation_Frequency,
    SUM(g.Gf_Amount) AS total_donated_amount 
FROM 
	Transf_gift_data g
	LEFT JOIN Removed_dup_donor d ON g.Gf_CnBio_ID = d.CnBio_ID
where d.CnBio_No_Valid_Addresses = 'Yes' ||  d.invalid_email = 'TRUE'
GROUP BY g.Gf_CnBio_ID,d.CnBio_Name
ORDER BY 4 DESC;

-- Donor Retention KPI

with temp as (
 select distinct
 Gf_CnBio_ID,
 year_donated 
 from Camp_Korey.Transf_gift_data
 where Gf_CnBio_ID is not null and Gf_CnBio_ID <> ''
 )
  ,temp2 as(
 select 
 Gf_CnBio_ID
 , year_donated
 , lead(year_donated) over(partition by Gf_CnBio_ID order by year_donated) next_donation_year
 , lag(year_donated) over (partition by Gf_CnBio_ID order by year_donated) as prev_donation_year
 , min(year_donated) over (partition by Gf_CnBio_ID)
 , max(year_donated) over (partition by Gf_CnBio_ID)
from temp
order by 1
 )
,
temp3 as(
select Gf_CnBio_ID
, max(year_donated) as max_year_donated
, min(year_donated) as min_year_donated
, max(next_donation_year) as max_next_donation_year
, min(next_donation_year) as min_next_donation_year
, max(prev_donation_year) as max_prev_donation_year
, min(prev_donation_year) as min_prev_donation_year

 from temp2
 group by 1
 )
 select a.Gf_CnBio_ID 
 , b.year
 , case when year = 2020 and min_year_donated = 2020 then 'New'
      when year = 2021 and min_year_donated = 2021 then 'New'
      when year = 2021 and (min_year_donated = 2020 and max_year_donated = 2021) then 'Return'
      when year = 2021 and (min_year_donated = 2020 and max_year_donated = 2020) then 'Lost'
      when year = 2021 and (min_year_donated = 2020 and max_year_donated = 2022 and max_prev_donation_year = 2020) then 'Lost'
      when year = 2021 and (min_year_donated = 2020 and max_year_donated = 2022 and max_prev_donation_year = 2021) then 'Return'
      when year = 2022 and min_year_donated = 2022 then 'New'
      when year = 2022 and ((min_year_donated = 2020 or min_year_donated= 2021) and max_year_donated = 2022) then 'Return'
      when year = 2022 and (max_year_donated = 2021 or max_year_donated = 2020) then 'Lost'
      else null 
      end as donor_type, 
      c.invalid_email,
      c.CnBio_No_Valid_Addresses,
      c.dne,
      c.dnc,
      c.dnm
 
 from temp3 a join (select distinct year_donated  as year from Camp_Korey.Transf_gift_data )b
 left join donor_duplicate c on a.Gf_CnBio_ID = c.CnBio_ID
 
 ;
