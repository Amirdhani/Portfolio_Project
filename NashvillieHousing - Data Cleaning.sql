Select *
From PortfolioProject..NashvilleHousing

-- Standardized Date Format
Select SaleDate,Convert(Date,SaleDate) SaleDateConverted
From NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)


-- Populate Property Address Data
Select *
From NashvilleHousing
Order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
On a.ParcelID = b.ParcelID And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
 On a.ParcelID = b.ParcelID And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null


-- Breaking Out address into individual columns(Address,City,States)
Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress varchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CharIndex(',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity varchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress,CharIndex(',',PropertyAddress)+1,Len(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress varchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity varchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState varchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

Select *
From PortfolioProject..NashvilleHousing


-- Change Y and N to Yes and No in "Sold as vacant" field
Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case
    When SoldAsVacant ='Y' Then 'Yes'
    When SoldAsVacant ='N' Then 'No'
    Else SoldAsVacant
End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case 
                       When SoldAsVacant ='Y' Then 'Yes'
                       When SoldAsVacant ='N' Then 'No'
                       Else SoldAsVacant
                    End


-- Remove Duplicate
With RowNumCTE As(
Select *,
ROW_NUMBER() Over(
Partition by ParcelID,
             PropertyAddress,
             SalePrice,
             SaleDate,
             LegalReference
             ORDER BY 
                 UniqueID
               ) row_num
From PortfolioProject..NashvilleHousing
)
Select *
From RowNumCTE
--Where row_num > 1
Order by PropertyAddress

Select *
From PortfolioProject..NashvilleHousing


-- Delete Unused Columns
Select *
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress,SaleDate