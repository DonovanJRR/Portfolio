/*

Cleaning Data in SQL Queries

*/

SELECT *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT saledate
From PortfolioProject.dbo.NashvilleHousing

SELECT saledateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

Alter TABLE NashvilleHousing
add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
From PortfolioProject.dbo.NashvilleHousing
where propertyAddress is NULL

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
ORDER by ParcelID

SELECT a.ParcelID, a.propertyAddress, b.ParcelID, b.propertyAddress, ISNULL(a.PropertyAddress,b.propertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.uniqueID
WHERE a.propertyAddress is NULL

UPDATE a
SET propertyAddress = ISNULL(a.PropertyAddress,b.propertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.uniqueID
WHERE a.propertyAddress is NULL
----  the query updates the propertyAddress in rows with missing addresses by looking for matching parcels in the same table but with different unique identifiers, and filling in the missing address from the corresponding row where the address is available. The ISNULL function is used to prioritize the address from the current row (a) if it's available, otherwise it takes the address from the corresponding row (b).

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT propertyaddress
from PortfolioProject.dbo.nashvillehousing
--where propertyaddress is null
--parcelid

SELECT
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)) as Address
from PortfolioProject.dbo.nashvillehousing


SELECT
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', propertyaddress), LEN(propertyAddress)) AS address
from PortfolioProject.dbo.nashvillehousing

-- to delete the comma

SELECT
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyAddress)) AS address
from PortfolioProject.dbo.nashvillehousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
add PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(propertyAddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress))

SELECT * 
from PortfolioProject.dbo.nashvillehousing

SELECT owneraddress
from PortfolioProject.dbo.nashvillehousing


SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
from PortfolioProject.dbo.nashvillehousing


SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress,',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
from PortfolioProject.dbo.nashvillehousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add ownerSplitAddress Nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
SET ownerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
add ownerSplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET ownerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
add ownerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET ownerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)


SELECT * 
from PortfolioProject.dbo.nashvillehousing



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP by SoldAsVacant
order by 2

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' Then 'No'
       Else SoldAsVacant
       END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' Then 'No'
       Else SoldAsVacant
       END


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP by SoldAsVacant
order by 2


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                ORDER BY
                    uniqueID
                 )row_num


FROM PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)

--DELETE 
SELECT *
FROM RowNumCTE
Where row_num > 1
--Order by PropertyAddress

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN saledate, OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN saledate