-- Standardise Date Format date time 

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

select saleDateConverted, SaleDate
From [Cleaning Project].dbo.NashvilleHousing

 --------------------------------------------------------------------------------------------------------------------------

-- This SQL code populates NULL PropertyAddress values in the NashvilleHousing table by matching ParcelID values via a self-join, using the non-null value from a different row:


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
--The ISNULL function is used to return the non-null value between a.PropertyAddress and b.PropertyAddress.
From [Cleaning Project].dbo.NashvilleHousing a
--We are specifying that the data will be retrieved from the NashvilleHousing table in the Cleaning Project database schema, and referring to it as "a".
JOIN [Cleaning Project].dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]  b.[UniqueID ]
--We are joining the NashvilleHousing table with itself based on matching ParcelID values.
--The condition a.[UniqueID]  b.[UniqueID] ensures that we don't match the same row with itself.
Where a.PropertyAddress is null
--We are filtering the rows where the PropertyAddress column in table a is null.

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
--We are updating the PropertyAddress column in table a with the non-null value from either a.PropertyAddress or b.PropertyAddress.
From [Cleaning Project].dbo.NashvilleHousing a
JOIN [Cleaning Project].dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]  b.[UniqueID ]
--We are performing the same self-join operation as before to ensure consistency between the update and the join.
Where a.PropertyAddress is null
--We are applying the same filter as before to update only the rows where the PropertyAddress column in table a is null.
--there are now none that have null in there


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State).. it is currently written as e.g. '617  LONGHUNTER CT, NASHVILLE'


Select PropertyAddress
From [Cleaning Project].dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
--this is going to the first value of PropertyAddress then going untill the comma
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
--this now starts after the comma, and finishes at the end
From [Cleaning Project].dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
--adding this as a new collum


Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )
--add the results


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);
--adding this as a new collum


Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))
--add the results, setting the city to that substring



Select *
From [Cleaning Project].dbo.NashvilleHousing
--confirming these have been added

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Cleaning Project].dbo.NashvilleHousing
Group by SoldAsVacant
order by 2
-- show some are Y & N, others are Yes & No

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
   When SoldAsVacant = 'N' THEN 'No'
   ELSE SoldAsVacant
   END
From [Cleaning Project].dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
   When SoldAsVacant = 'N' THEN 'No'
   ELSE SoldAsVacant
   END

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Cleaning Project].dbo.NashvilleHousing
Group by SoldAsVacant
order by 2
-- show its been updated



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH DeduplicatedData AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertySplitAddress, SalePrice, LegalReference
--PARTITIONING ON THINGS THAT SHOULD BE UNIQUE TO EACH ROW
            ORDER BY UniqueID
        ) AS row_num
    FROM [Cleaning Project].dbo.NashvilleHousing
)
SELECT *
FROM DeduplicatedData
WHERE row_num = 1
ORDER BY PropertySplitAddress;


--In summary, this query deduplicates the data in the [Cleaning Project].dbo.NashvilleHousing table based on the columns ParcelID, PropertySplitAddress, SalePrice, LegalReference. 
--It returns only the first occurrence of each set of duplicates and sorts the result by PropertySplitAddress
--This uses a CTE (Common Table Expression) named DeduplicatedData. A CTE is a temporary named result set that you can reference within a SQL statement. 



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From [Cleaning Project].dbo.NashvilleHousing

ALTER TABLE [Cleaning Project].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
