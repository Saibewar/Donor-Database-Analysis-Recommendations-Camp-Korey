-- checking donor segmentation

drop table if exists ckschema.donor_levels;
create table ckschema.donor_levels as
select 
	d.CnBio_ID,
    g.Gf_CnBio_ID
    ,year(g.Gf_Date) as Year_donated
    ,count(distinct g.Gf_Gift_ID) as NumberOfGifts
    ,sum(g.Gf_Amount) as TotalGiftAmount
    ,round(avg(g.Gf_Amount),2) as AverageGiftAmount
    ,case when sum(g.Gf_Amount) > 2500 then 'Large amount donors' else 'Small amount donors' end as Giving_Level
from 
	ckschema.bio_donor d
    left join ckschema.gift_analysis g
		on g.Gf_CnBio_ID = d.CnBio_ID
where
	d.CnBio_Constit_Code = 'Individual'
group by
	d.CnBio_ID, year(g.Gf_Date);
select * from donor_levels;


-- break down of total amount by donor levels
select Giving_Level, Year_donated, count(distinct CnBio_ID),
	sum(TotalGiftAmount),	sum(NumberOfGifts)
from ckschema.donor_levels
where Year_donated is not null
group by
	Year_donated, Giving_Level
order by 2,1;


-- count of individual donors by levels
select count(CnBio_ID),Giving_Level from donor_levels
	group by Giving_Level;
    
    -- count of individual donors by levels
select count(CnBio_ID),Giving_Level from donor_levels
	group by Giving_Level;


-- Capstone II 

#Segmentation of donors based on county
#Output-1
-- 
SELECT g.Gf_CnBio_ID,z.County
FROM gift_analysis g
LEFT JOIN zip_codes_county z ON LEFT(g.Gf_CnAdrPrf_ZIP, 5) = z.Zip_Code
WHERE LEFT(Gf_CnAdrPrf_ZIP, 1) = '9'
GROUP BY z.County,g.Gf_CnBio_ID;

#Output-2
-- Count of donations, total amount of donations county in WA
SELECT count(g.Gf_CnBio_ID),sum(g.Gf_Amount) as Total_amount, z.County
FROM gift_analysis g
LEFT JOIN zip_codes_county z ON LEFT(g.Gf_CnAdrPrf_ZIP, 5) = z.Zip_Code
WHERE LEFT(Gf_CnAdrPrf_ZIP, 1) = '9'
GROUP BY z.County
ORDER BY count(g.Gf_CnBio_ID) DESC;

select distinct County from zip_codes_county
GROUP BY County;


