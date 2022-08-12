--- Cleaning Data in SQL Queries

SELECT *
FROM PortfolioProjectSQL1..HouseEDA


--- Populate property address data

SELECT PropertyAddress
FROM PortfolioProjectSQL1..HouseEDA
WHERE PropertyAddress IS NULL

SELECT *
FROM PortfolioProjectSQL1..HouseEDA
WHERE PropertyAddress IS NULL

SELECT
    a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress
FROM PortfolioProjectSQL1..HouseEDA AS a
INNER JOIN PortfolioProjectSQL1..HouseEDA AS b
    ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


SELECT
    a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjectSQL1..HouseEDA AS a
INNER JOIN PortfolioProjectSQL1..HouseEDA AS b
    ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjectSQL1..HouseEDA AS a
INNER JOIN PortfolioProjectSQL1..HouseEDA AS b
    ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


--- Breaking out address into individual columns

SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress))
FROM PortfolioProjectSQL1..HouseEDA

--- Removing coma from column

SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
FROM PortfolioProjectSQL1..HouseEDA

--- Watch output

SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
FROM PortfolioProjectSQL1..HouseEDA

--- Now separate after the coma into new column

SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProjectSQL1..HouseEDA

--- Adding new columns to the table

ALTER TABLE PortfolioProjectSQL1..HouseEDA
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProjectSQL1..HouseEDA
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE PortfolioProjectSQL1..HouseEDA
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProjectSQL1..HouseEDA
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProjectSQL1..HouseEDA


ALTER TABLE PortfolioProjectSQL1..HouseEDA
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProjectSQL1..HouseEDA
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE PortfolioProjectSQL1..HouseEDA
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProjectSQL1..HouseEDA
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE PortfolioProjectSQL1..HouseEDA
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProjectSQL1..HouseEDA
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--- Change 1 and 0 to Yes and No in "Sold as Vacant" column

SELECT DISTINCT(SoldAsVacant)
FROM PortfolioProjectSQL1..HouseEDA


SELECT
    SoldAsVacant,
	CASE WHEN SoldAsVacant = '0' THEN 'No'
	WHEN SoldAsVacant = '1' THEN 'Yes'
	END
FROM PortfolioProjectSQL1..HouseEDA


ALTER TABLE PortfolioProjectSQL1..HouseEDA
ALTER COLUMN SoldAsVacant Nvarchar(255);


UPDATE PortfolioProjectSQL1..HouseEDA
SET SoldAsVacant = CASE WHEN SoldAsVacant = '0' THEN 'No'
	WHEN SoldAsVacant = '1' THEN 'Yes'
	END
FROM PortfolioProjectSQL1..HouseEDA
	

--- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				 UniqueID
				 ) row_num
FROM PortfolioProjectSQL1..HouseEDA
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


--- Delete Unused Columns


SELECT *
FROM PortfolioProjectSQL1..HouseEDA


ALTER TABLE PortfolioProjectSQL1..HouseEDA
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProjectSQL1..HouseEDA
DROP COLUMN SaleDate