-- conveting saledate from datetime to date
select SaleDate, CONVERT(date, saledate)
from [Portfolio 2]..Nashvillehousing;

update Nashvillehousing
set SaleDate=CONVERT(date,saledate);

alter table Nashvillehousing
add sale_date_new date

update Nashvillehousing
set sale_date_new=CONVERT(date,saledate);



-- populating NULL property address when its supposed to have data
-- same property addressess have same parcel id but different unique id therefore we can use this to populate the data where null
select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfolio 2]..Nashvillehousing as a
join [Portfolio 2]..Nashvillehousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a. PropertyAddress is null;

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfolio 2]..Nashvillehousing as a
join [Portfolio 2]..Nashvillehousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a. PropertyAddress is null;

select * 
from [Portfolio 2]..Nashvillehousing
where PropertyAddress is null



-- splitting property address into address and city columns using substring
select * 
from [Portfolio 2]..Nashvillehousing 

select PropertyAddress, 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1), 
SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyaddress))
from [Portfolio 2]..Nashvillehousing 

alter table Nashvillehousing
add propertyadd nvarchar(255)

update Nashvillehousing
set propertyadd= SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table Nashvillehousing
add propertycity nvarchar(255)

update Nashvillehousing
set propertycity= SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyaddress))



-- splitting ownersaddress using parsename
select
owneraddress,
PARSENAME(REPLACE(owneraddress, ',' , '.'), 3),
PARSENAME(REPLACE(owneraddress, ',' , '.'), 2),
PARSENAME(REPLACE(owneraddress, ',' , '.'), 1)
from [Portfolio 2]..Nashvillehousing 

alter table Nashvillehousing
add owneradd nvarchar(255)

update Nashvillehousing
set owneradd= PARSENAME(REPLACE(owneraddress, ',' , '.'), 3)

alter table Nashvillehousing
add ownercity nvarchar(255)

update Nashvillehousing
set ownercity= PARSENAME(REPLACE(owneraddress, ',' , '.'), 2)

alter table Nashvillehousing
add ownerstate nvarchar(255)

update Nashvillehousing
set ownerstate= PARSENAME(REPLACE(owneraddress, ',' , '.'), 1)

select *
from [Portfolio 2]..Nashvillehousing 



-- changinging soldasvacant column to only yes and no
select distinct (soldasvacant)
from [Portfolio 2]..Nashvillehousing 

select SoldAsVacant,
case when SoldAsVacant ='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end
from [Portfolio 2]..Nashvillehousing 

update Nashvillehousing
set SoldAsVacant= case when SoldAsVacant ='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end



--removing duplicates
--if rownum>1 then row is possibly duplicate
select *,
	ROW_NUMBER() over(partition by parcelID,
								   propertyaddress,
								   saleprice,
								   saledate,
								   legalreference
						order by uniqueID) rownum
from [Portfolio 2]..Nashvillehousing 

--creating CTE to show duplicate rows
with rownumCTE as(
select *,
	ROW_NUMBER() over(partition by parcelID,
								   propertyaddress,
								   saleprice,
								   saledate,
								   legalreference
						order by uniqueID) rownum
from [Portfolio 2]..Nashvillehousing 
)
select *
from rownumCTE
where rownum > 1
order by parcelid

--deleting duplicate rows
with rownumCTE as(
select *,
	ROW_NUMBER() over(partition by parcelID,
								   propertyaddress,
								   saleprice,
								   saledate,
								   legalreference
						order by uniqueID) rownum
from [Portfolio 2]..Nashvillehousing 
)
delete
from rownumCTE
where rownum > 1



-- deleting unused columns
select * 
from [Portfolio 2]..Nashvillehousing 

alter table [Portfolio 2]..Nashvillehousing 
drop column propertyaddress, saledate, taxdistrict, owneraddress
