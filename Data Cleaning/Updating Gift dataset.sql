/* To update the constitutent ID of the donors in the gift dataset */


/* Dataset : donor_duplicate - Donor data with duplicate bio id, 
Transf_gift_data - Updated gift dataset */


with donor_rank as
(
SELECT CnBio_ID,CnBio_Name,CnBio_Last_Name,CnBio_First_Name,CnBio_Constit_Code,CnBio_Gender,CnBio_Marital_status,
CnBio_No_Valid_Addresses,CnAdrSal_Addressee,CnAdrSal_Salutation,CnAdrPrf_City,CnAdrPrf_State,CnAdrPrf_ZIP, 
row_number()OVER(PARTITION BY CnBio_Name,CnBio_Last_Name,CnBio_First_Name,CnBio_Constit_Code,CnBio_Gender,CnBio_Marital_status,
CnBio_No_Valid_Addresses,CnAdrSal_Addressee,CnAdrSal_Salutation,CnAdrPrf_City,CnAdrPrf_State,CnAdrPrf_ZIP) as  Rownumber
FROM donor_duplicate
)
,
distinct_donor as
(
select *
from Removed_dup_donor -- donor_rank 
-- where Rownumber = 1
)
,
final as (
select 
a.CnBio_ID,
b.CnBio_ID as b_CnBio_ID
/*
a.CnBio_Name,
a.CnBio_Last_Name,
a.CnBio_First_Name,
a.CnBio_Constit_Code,
a.CnBio_Gender,
a.CnBio_Marital_status,
a.CnBio_No_Valid_Addresses,
a.CnAdrSal_Addressee,
a.CnAdrSal_Salutation,
a.CnAdrPrf_City,
a.CnAdrPrf_State,
a.CnAdrPrf_ZIP
*/
from donor_duplicate a JOIN
distinct_donor b on 
a.CnBio_Name = b.CnBio_Name and 
a.CnBio_Last_Name = b.CnBio_Last_Name and 
a.CnBio_First_Name = b.CnBio_First_Name and 
a.CnBio_Constit_Code = b.CnBio_Constit_Code and 
a.CnBio_Gender = b.CnBio_Gender and 
a.CnBio_Marital_status = b.CnBio_Marital_status and 
a.CnBio_No_Valid_Addresses = b.CnBio_No_Valid_Addresses and 
a.CnAdrSal_Addressee = b.CnAdrSal_Addressee and 
a.CnAdrSal_Salutation = b.CnAdrSal_Salutation and 
a.CnAdrPrf_City = b.CnAdrPrf_City and 
a.CnAdrPrf_State = b.CnAdrPrf_State and 
a.CnAdrPrf_ZIP = b.CnAdrPrf_ZIP
)

-- SELECT * FROM  FINAL;
update Transf_gift_data a           
join final b on a.Gf_CnBio_ID = b.CnBio_ID
set a.Gf_CnBio_ID = b.b_CnBio_ID
;