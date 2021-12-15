												
												---- DATA CLEANING ----

----------------------------------------------------------------------------------------------------------------------------------

select *
from PortfolioProject..NashvilleHousing

-- Standarisasi Format Tanggal --
-- Mengubah format tanggal menjadi lebih sederhana / menghilangkan 00:00:00.000 pada SaleDate

select SaleDate
from PortfolioProject.dbo.NashvilleHousing

select SaleDate, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

alter table PortfolioProject.dbo.NashvilleHousing
add SaleDateConverted Date;

update PortfolioProject.dbo.NashvilleHousing
set SaleDateConverted = CONVERT(Date,SaleDate)

select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------

-- Mengisi PropertyAddress yang memiliki nilai null dengan menggunakan join pada 1 tabel
-- PropertyAddress yang memiliki nilai null diisi dengan PropertyAddress not null berdasarkan ParcelID yang sama

select *
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a	-- tabel diinisialisasi menjadi a dan b
join PortfolioProject.dbo.NashvilleHousing b	--Join pada satu tabel
	on a.ParcelID = b.ParcelID					--Memiliki ParcelID yang sama
	and a.[UniqueID ] <> b.[UniqueID ]			--Tapi memiliki UniqueID yang berbeda
where a.PropertyAddress is null

-- isnull(a.PropertyAddress,b.PropertyAddress) ARTINYA jika a.PropertyAddress kosong maka isi dengan b.PropertyAddress
-- Setelahnya baru dilakukan update

update a								-- a adalah PortfolioProject.dbo.NashvilleHousing kolom PropertyAddress yang akan diupdate
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------------------

--- Memecah Address menjadi kolom tersendiri (Alamat, Kota, Negara)
-- Menggunakan SUBSRTING

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

--SUBSTRING(PropertyAddress, 1,  charindex(',', PropertyAddress) adalah untuk mencari karakter pertama sampai tanda koma 
--yang akan dipisah dengan nama negara/kata terakhir
-- -1 adalah untuk menghilangkan karakter koma pada PropertyAddress/menghilangkan satu karakter dari kanan
-- SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Address artinya menampilkan address setelah tanda koma

alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitAddress Nvarchar(255);		--Membuat kolom baru bernama PropertySplitAddress untuk mengisi address sebelum tanda koma

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
--Isi kolom PropertySplitAddress dengan address sebelum koma

alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitCity Nvarchar(255);		--Membuat kolom baru bernama PropertySplitCity untuk mengisi address setelah tanda koma

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))
--Isi kolom PropertySplitAddress dengan address setelah koma

select *
from PortfolioProject.dbo.NashvilleHousing

-- Menggunakan PARSENAME

select 
PARSENAME(replace(OwnerAddress, ',', '.'), 3),	-- Memisahkan OwnerAddress (Diurutkan dengan terbalik(3, 2, 1) agar runut menjadi alamat, kota, dan negara)
PARSENAME(replace(OwnerAddress, ',', '.'), 2),	-- Memisahkan OwnerCity (Diurutkan dengan terbalik(3, 2, 1) agar runut menjadi alamat, kota, dan negara)
PARSENAME(replace(OwnerAddress, ',', '.'), 1)	-- Memisahkan OwnerState (Diurutkan dengan terbalik(3, 2, 1) agar runut menjadi alamat, kota, dan negara)
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress Nvarchar(225);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitCity Nvarchar(225);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitState Nvarchar(225);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

select *
from PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------

--- Mengubah Y dan N Menjadi Yes dan No pada kolom SoldAsVacant
-- Melihat isi kolom SoldAsVacant terlebih dahulu

select distinct(SoldAsVacant), COUNT(SoldAsVacant)	-- Mengambil jenis isi kolom SoldAsVacant dan menghitung banyaknya 
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2	-- Mengurutkan count dari yang terkecil ke terbesar

--Mengubah Y dan N menggunakan case statement dan kondisi when

select SoldAsVacant, 
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject.dbo.NashvilleHousing

--Kemudian baru update kolom setelah Y dan N diubah

update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
--Lihat lagi (menggunakan distinct seperti di atas) apakah Y dan N isi kolom SoldAsVacant sudah tidak ada

----------------------------------------------------------------------------------------------------------------------------------

-- Menghapus Duplikasi Data
	-- Pertama mencari data yang memiliki duplikasi

select *,
	row_number() over
	(
		partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 order by
						UniqueID
										) row_num
from PortfolioProject.dbo.NashvilleHousing
order by ParcelID

	--Kemudian memakai CTE dan hapus row_num > 1
with RowNumCTE as 
(
	select *,
	row_number() over
	(
		partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 order by
						UniqueID
										) row_num
from PortfolioProject.dbo.NashvilleHousing
)
select *					-- Pertama gunakan select * untuk melihat row_num > 1 kemudian gunakan delete jika row_num > 1
--delete					-- kemudian gunakan delete jika row_num > 1
from RowNumCTE				-- Kemudian gunakan select * lagi untuk melihat row_num > 1 sudah terhapus/tidak ada
where row_num > 1
order by PropertyAddress	-- gunakan order by untuk melihat row_num > 1 berdasarkan kolom tertentu
							-- dan hilangkan order by saat delete row_num > 1


-- Menghapus Kolom yang Tidak DIbutuhkan
	-- Menghapus kolom PropertyAddress, OwnerAddress karena sudah dipisahkan di atas
	-- Menghapus SaleDate karena sudah dibuat menjadi kolom baru dengan format yang sederhana

alter table PortfolioProject.dbo.NashvilleHousing
drop column PropertyAddress, SaleDate, TaxDistrict, OwnerAddress

select *
from PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------

									--------------- TERIMA KASIH ---------------