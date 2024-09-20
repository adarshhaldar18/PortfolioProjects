/*

Cleaning the data with sql queries

*/


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


------------------------------------------------------------------------
--Standardize Data Format

SELECT SaleDate , CONVERT(date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

----If it doesn't update properly

ALTER Table NashvilleHousing
ADD SaleDateConverted Date ;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

--------------------------------------------------------------------------------

-- Populate the PropertyAddress


SELECT PropertyAddress   --Checking for null values
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null;

SELECT *                     --Checking everything where null values present
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null;

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER by ParcelID
--From this we can see two rows with same parcelID also have same propertyaddress.
--Therefore if one parcelID have null propertyaddress but the second have propertyaddress
--then we can populate the first parcelID with the help of second propertyaddress.

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

------------------------------------------------------------------------------------------
-- Breaking out Address into Individual columns (Address,City,State)

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.NashvilleHousing

ALTER Table PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255) ;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER Table PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255) ;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


-----------------------------------------------------------------------------------
--Handling Owner Address 

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE OwnerAddress is null

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER Table PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255) ;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER Table PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255) ;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER Table PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255) ;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------
--Change Y and N into Yes and No in SoldAsVacant column

SELECT DISTINCT(SoldAsVacant),Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END


---------------------------------------------------------------------------------
--Removing duplicates
WITH RowCTE AS (
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
				     SaleDate,
					 PropertyAddress,
					 LegalReference,
					 SalePrice
					 ORDER BY
							UniqueID
					) row_num
					
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER By ParcelID
)
SELECT *                 ---
FROM RowCTE                 -------For fetching the duplicates
WHERE row_num >1         ---

--DELETE                  ----
--FROM RowCTE                 ---------For deleting the duplicates
--WHERE row_num >1        ---
 
Select *
From PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


