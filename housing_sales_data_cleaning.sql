/*

Data Cleaning Queries

*/

-------------------------------------------------------------------------------------------------------------------------


/* Standarize Data Format: Convert Datetime to Date Type */

ALTER TABLE nashville_housing
ALTER COLUMN SaleDate date NOT NULL


-------------------------------------------------------------------------------------------------------------------------


/* Populate Property Address Data: Replace Null PropertyAddress */

-- Rename UniqueID without the trailing space
EXEC sp_rename 'PortfolioProject.dbo.nashville_housing.UniqueID ', 'UniqueID', 'COLUMN';

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


-------------------------------------------------------------------------------------------------------------------------


/* Split Address to Different Columns (Street, City, State) */

-- Split Property Address
ALTER TABLE nashville_housing
ADD PropertyStreet Nvarchar(255), PropertyCity Nvarchar(255)

UPDATE nashville_housing
SET PropertyStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
	, PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 


-- Split Owner Address
ALTER TABLE nashville_housing
ADD OwnerStreet Nvarchar(255), OwnerCity Nvarchar(255), OwnerState Nvarchar(255)

UPDATE nashville_housing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
	, OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
	, OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-------------------------------------------------------------------------------------------------------------------------


/* Change Y and N to Yes and No in SoldAsVacant Column */

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2

UPDATE nashville_housing
SET SoldAsVacant = 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END


-------------------------------------------------------------------------------------------------------------------------


/* Remove Duplicates */

WITH row_num_cte AS (
	SELECT *,
		-- Use ROW_NUMBER() OVER() to look for rows with the same values as the columns below
		ROW_NUMBER() OVER (         
			PARTITION BY ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY
							UniqueID
		) Row_Num
	FROM nashville_housing
)

DELETE
FROM row_num_cte
WHERE Row_Num > 1


-------------------------------------------------------------------------------------------------------------------------


/* Delete Unused Columns */

SELECT * 
FROM nashville_housing

ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress, PropertyAddress










/*
	Original Data Source: https://www.kaggle.com/tmthyjames/nashville-housing-data
*/
 