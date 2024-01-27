/*
donor_duplicate	    Contains duplicate donor IDs
Transf_gift_data	Cleaned gift dataset using python 
Removed_dup_donor	Donor table after removing duplicate IDs
dup_donor_list	    List of Duplicate IDs removed
*/

USE CAMP_KOREY;

-- Creat Table for Transformed Donor Data:
Create Table donor_duplicate
(
CnBio_Name text,
CnBio_Last_Name text,
CnBio_First_Name text,
CnBio_ID int,
CnBio_SortKey varchar(50),
CnBio_Age int,
CnBio_Constit_Code text,
CnBio_Gender text,
CnBio_Marital_status text,
CnBio_No_Valid_Addresses text,
CnBio_Matching_Gift_Flag text,
CnAdrSal_Addressee text,
CnAdrSal_Salutation text,
CnAdrPrf_City text,
CnAdrPrf_State text,
CnAdrPrf_ZIP varchar(20),
CnCnstncy_1_01_Date_From text,
CnCnstncy_1_01_Date_To text,
CnSpSpBio_Name text,
CnSolCd_1_01_Solicit_Code varchar(50),
CnSolCd_1_02_Solicit_Code varchar(50),
CnSolCd_1_03_Solicit_Code varchar(50),
CnSolCd_1_04_Solicit_Code varchar(50),
CnSolCd_1_05_Solicit_Code varchar(50),
dne varchar(20),
dnc varchar(20),
dnm varchar(20),
invalid_email varchar(20),
prim_email varchar(50)

);

DROP TABLE IF EXISTS Transf_gift_data;
CREATE TABLE Transf_gift_data
(
Gf_Gift_ID int,
Gf_Amount float,
Gf_Date DATETIME,
Gf_Type varchar(100),
Gf_Appeal varchar(100),
Gf_Fund varchar(100),
Gf_Campaign varchar(100),
Gf_CnBio_ID varchar(100),
Gf_CnBio_Age varchar(100),
Gf_CnBio_Gender varchar(100),
Gf_CnBio_Inactive varchar(100),
Gf_CnBio_Marital_status varchar(100),
Gf_CnBio_Name varchar(100),
Gf_CnBio_Month_born varchar(100),
Gf_CnBio_No_Valid_Addresses varchar(100),
Gf_CnBio_Year_born int,
Gf_CnAdrPrf_Addrline1 varchar(100),
Gf_CnAdrPrf_Addrline2 varchar(100),
Gf_CnAdrPrf_Addrline3 varchar(100),
Gf_CnAdrPrf_Addrline4 varchar(100),
Gf_CnAdrPrf_Addrline5 varchar(100),
Gf_CnAdrPrf_City varchar(100),
Gf_CnAdrPrf_ContryLongDscription varchar(100),
Gf_CnAdrPrf_OrgName varchar(100),
Gf_CnAdrPrf_Position varchar(100),
Gf_CnAdrPrf_State varchar(100),
Gf_CnAdrPrf_ZIP varchar(100),
Gf_CnPh_1_01_Phone_number varchar(100),
Gf_CnPh_1_02_Phone_number varchar(100),
Gf_CnPh_1_03_Phone_number varchar(100),
Gf_CnPh_1_04_Phone_number varchar(100),
Gf_CnPh_1_05_Phone_number varchar(100),
year_donated varchar(100),
month_donated varchar(100),
Gf_Fund_Old varchar(100)
);

-- Load the Transformed data

SET GLOBAL local_infile=1;
LOAD DATA LOCAL INFILE '/Users/kat/Cleaned_Donor_bio1.csv'
INTO TABLE CAMP_KOREY.donor_duplicate
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Check for the duplicates by using CTE method :

Create Table Removed_dup_donor
(
with donor_rank as
(
SELECT CnBio_Name,CnBio_Last_Name,CnBio_First_Name,CnBio_Constit_Code,CnBio_Gender,CnBio_Marital_status,
CnBio_No_Valid_Addresses,CnAdrSal_Addressee,CnAdrSal_Salutation,CnAdrPrf_City,CnAdrPrf_State,CnAdrPrf_ZIP, 
row_number()OVER(PARTITION BY CnBio_Name,CnBio_Last_Name,CnBio_First_Name,CnBio_Constit_Code,CnBio_Gender,CnBio_Marital_status,
CnBio_No_Valid_Addresses,CnAdrSal_Addressee,CnAdrSal_Salutation,CnAdrPrf_City,CnAdrPrf_State,CnAdrPrf_ZIP) as  Rownumber
FROM donor_duplicate
)
select *
from donor_rank 
where Rownumber = 1);

-- List of Bio ID which has been removed
Create Table dup_donor_list
(
with donor_rank as
(
SELECT CnBio_ID,CnBio_Name,CnBio_Last_Name,CnBio_First_Name,CnBio_Constit_Code,CnBio_Gender,CnBio_Marital_status,
CnBio_No_Valid_Addresses,CnAdrSal_Addressee,CnAdrSal_Salutation,CnAdrPrf_City,CnAdrPrf_State,CnAdrPrf_ZIP, 
row_number()OVER(PARTITION BY CnBio_Name,CnBio_Last_Name,CnBio_First_Name,CnBio_Constit_Code,CnBio_Gender,CnBio_Marital_status,
CnBio_No_Valid_Addresses,CnAdrSal_Addressee,CnAdrSal_Salutation,CnAdrPrf_City,CnAdrPrf_State,CnAdrPrf_ZIP) as  Rownumber
FROM donor_duplicate
)
select *
from donor_rank 
where Rownumber > 1);


-- Extracting the tables to report
select * from Removed_dup_donor;

select * from dup_donor_list;
