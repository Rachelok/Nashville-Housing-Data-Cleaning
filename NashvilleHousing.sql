/*

Rachel Ok
Nashville Housing Data Cleaning Project from https://www.kaggle.com/datasets/tmthyjames/nashville-housing-data
May 10, 2022

*/
Select *
From [Portfolio Project].dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Here we are going to Standardize the date format.

Select SaleDateConverted, CONVERT(Date, SaleDate)
From [Portfolio Project].dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populating Property Address Data.

Select *
From [Portfolio Project].dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID

-- Within the data, there are rows with the same Parcel ID but empty Property Addresses so I am going to fill in the empty addresses with ones with the same Parcel ID.
Select f.ParcelID, f.PropertyAddress, e.ParcelID, e.PropertyAddress, ISNULL(f.PropertyAddress, e.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing f
JOIN [Portfolio Project].dbo.NashvilleHousing e
	on f.ParcelID = e.ParcelID
	and f.[UniqueID ] <> e.[UniqueID ]
Where f.PropertyAddress is null

-- I updated the Property Addresses and ensured that no cells are empty.
Update f
SET PropertyAddress = ISNULL(f.PropertyAddress, e.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing f
JOIN [Portfolio Project].dbo.NashvilleHousing e
	on f.ParcelID = e.ParcelID
	and f.[UniqueID ] <> e.[UniqueID ]
Where f.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City Sate).

Select PropertyAddress
From [Portfolio Project].dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address-- I got the position of the comma where the address is divided then -1 to remove the comma.
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City -- I got the position of the comma where the address is divided then +1 to remove the comma.
From [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertyAddressUpdated Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyAddressUpdated = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertyCityUpdated Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyCityUpdated = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From [Portfolio Project].dbo.NashvilleHousing


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Dividing the Owner Address to separate Address, City and State.

Select OwnerAddress
From [Portfolio Project].dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerAddressUpdated Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerAddressUpdated = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerCityUpdated Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerCityUpdated = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerStateUpdated Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerStateUpdated = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From [Portfolio Project].dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold As Vacant" field

-- There are several data entries that are written as Y or N instead of yes or no. In order to make the data consistent, I will change the Y or N to Yes and No.


-- Out of curiosity, I wanted to count how many entries of Y, N, Yes and No there are
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From [Portfolio Project].dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
From [Portfolio Project].dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
			When SoldAsVacant = 'N' THEN 'No'
			Else SoldAsVacant
			END


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- I want to assume that if the Parcel ID, Property Address, Sale Price, Sale Date, Legal Reference number is the same, the data is a replica. Of course, I do not want to delete 
-- any data in real life.

WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [Portfolio Project].dbo.NashvilleHousing
)

DELETE
From RowNumCTE
where row_num >1



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From [Portfolio Project].dbo.NashvilleHousing


ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress