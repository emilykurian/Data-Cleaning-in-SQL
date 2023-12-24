/*

Cleaning Data in SQL Queries

*/

select *
from SQL_Demo.dbo.HousingData;

----------------------------------------------------------------------------------------------
-- Standrdize Data Format

Select SaleDateConverted
from SQL_Demo.dbo.HousingData

Update SQL_Demo.dbo.HousingData
set SaleDate = Convert(Date,SaleDate)  ----Doesn't work, instead did the below

alter table SQL_Demo.dbo.HousingData
add SaleDateConverted Date;

update SQL_Demo.dbo.HousingData
set SaleDateConverted = convert(Date,SaleDate)

--------------------------------------------------------------------------------------------------------------------

---- Populate property address data
Select *
from SQL_Demo.dbo.HousingData
where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.PropertyAddress, b.PropertyAddress)
from SQL_Demo.dbo.HousingData a
join SQL_Demo.dbo.HousingData b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from SQL_Demo.dbo.HousingData a
join SQL_Demo.dbo.HousingData b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]

-------------------------------------------------------------------------------------------------------------

---Breaking Address into individual columns (Address, City, State)

Select PropertyAddress
from SQL_Demo.dbo.HousingData

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+ 1, LEN(PropertyAddress)) as City
from SQL_Demo.dbo.HousingData

ALTER TABLE SQL_Demo.dbo.HousingData
ADD PropertySplitAddress NVARCHAR(255)

UPDATE SQL_Demo.dbo.HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE SQL_Demo.dbo.HousingData
ADD PropertySplitCity NVARCHAR(255)

UPDATE SQL_Demo.dbo.HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+ 1, LEN(PropertyAddress))

select PropertySplitAddress, PropertySplitCity
FROM SQL_Demo.dbo.HousingData

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
FROM SQL_Demo.dbo.HousingData

ALTER TABLE SQL_Demo.dbo.HousingData
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE SQL_Demo.dbo.HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 

ALTER TABLE SQL_Demo.dbo.HousingData
ADD OwnerSplitCity NVARCHAR(255)

UPDATE SQL_Demo.dbo.HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE SQL_Demo.dbo.HousingData
ADD OwnerSplitState NVARCHAR(255)

UPDATE SQL_Demo.dbo.HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM SQL_Demo.dbo.HousingData

-----------------------------------------------------------------------------------------------------------------------
------Change Y and N to Yes and No in "Sold as Vacant "Field

Select distinct SoldAsVacant, count(SoldAsVacant)
FROM SQL_Demo.dbo.HousingData
group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM SQL_Demo.dbo.HousingData

UPDATE HousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM SQL_Demo.dbo.HousingData

-------------------------------------------------------------------------------------------------------------------

-----Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
     ROW_NUMBER() OVER (
	 PARTITION BY ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
				  UniqueID
				  ) row_num

FROM SQL_Demo.dbo.HousingData
)

DELETE
FROM RowNumCTE 
WHERE row_num>1

-----------------------------------------------------------------------------------------------------------------------

----Delete unused columns

ALTER TABLE SQL_Demo.dbo.HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

SELECT *
FROM SQL_Demo.dbo.HousingData
