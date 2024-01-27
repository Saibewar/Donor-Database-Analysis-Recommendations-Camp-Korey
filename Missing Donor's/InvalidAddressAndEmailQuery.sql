
-- pulling all invalid address donors, ordered by total gift amount
create table ck.invalid_address as
select 
	d.CnBio_ID
    ,d.CnBio_Name
    ,case 
		when sum(g.Gf_Amount) is null then 0
        else round(sum(g.Gf_Amount),2) end as Total_Gift_Amount -- sum of all gifts for that donor id
from 
	ck.donor	d
    left join ck.gifts	g
		on d.CnBio_ID = g.Gf_CnBio_ID
where
	-- no valid address on file
    d.CnBio_No_Valid_Addresses = 'Yes'
group by
	d.CnBio_ID
    ,d.CnBio_Name
order by
	sum(g.Gf_Amount) desc
;

-- pulling all invalid email donors, ordered by total gift amount
create table ck.invalid_email as
select 
	d.CnBio_ID
    ,d.CnBio_Name
    ,case 
		when sum(g.Gf_Amount) is null then 0
        else round(sum(g.Gf_Amount),2) end as Total_Gift_Amount -- sum of all gifts for that donor id
from 
	ck.donor	d
    left join ck.gifts	g
		on d.CnBio_ID = g.Gf_CnBio_ID
where
	-- no valid address on file
    d.invalid_email = 'TRUE'
group by
	d.CnBio_ID
    ,d.CnBio_Name
order by
	sum(g.Gf_Amount) desc
;


