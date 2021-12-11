
select * 
from PortfolioProject..CovidDeaths
where continent is not null 
order by 3,4 

--select * 
--from PortfolioProject..CovidVaccination
--order by 3,4

--Memilih Data yang Akan digunakan

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Melihat Total Kasus vs Total Kematian
--Menunjukkan Persentase Kematian di Indonesia
select location, date, (cast(total_cases as float)) as total_cases,(cast(total_deaths as float)) as total_deaths, 
(cast(total_deaths as float))/(cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%Indonesia%'
and where continent is not null
order by 1,2

--Melihat Total Kasus vs Populasi
--Menunjukkan Persentase Populasi yang Terkena Covid di Indonesia
select location, date, (cast(total_cases as float)) as total_cases, population, 
(cast(total_cases as float))/(cast(population as float))*100 as Infected_Percentage
From PortfolioProject..CovidDeaths
where location like '%Indonesia%'
and where continent is not null
order by 1,2

-- Melihat Negara dengan Tingkat Infeksi Tertinggi Dibandingkan dengan Populasi

select location, population, max(cast(total_cases as float)) as Infeksi_Tertinggi, 
max(cast(total_cases as float))/(cast(population as float))*100 as Persentase_Infeksi_Tertinggi
From PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by Persentase_Infeksi_Tertinggi desc

-- Melihat Negara dengan Tingkat Kematian Tertinggi di Dunia
select location, max(cast(total_deaths as float)) as Total_Kematian
From PortfolioProject..CovidDeaths
where continent is not null
group by location
order by Total_Kematian desc

-- Melihat Benua dengan dengan Tingkat Kematian Tertinggi
select continent, max(cast(total_deaths as float)) as Total_Kematian
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by Total_Kematian desc

-- Melihat Angka Global Menurut Tanggal

select date, sum(cast(new_cases as float)) as total_cases, sum(cast(new_deaths as float)) as total_deaths, 
sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 
as Global_Deaths_Percentage From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Melihat Total Kasus dan Total Kematian

select sum(cast(new_cases as float)) as total_cases, sum(cast(new_deaths as float)) as total_deaths, 
sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 
as Global_Deaths_Percentage From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Melihat Banyaknya Populasi yang telah divaksin

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Melihat Roliing Banyaknya Populasi yang Telah Divaksin

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location, 
dea.date) as Rolling_People_Vaccinated
from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Memakai CTE

with popvsvac (continent, location, date, population, new_vaccination, Rolling_People_Vaccinated)

as

(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location, 
dea.date) as Rolling_People_Vaccinated
from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (Rolling_People_Vaccinated/population)*100 as Vaccination_Percentage
from popvsvac

-- TEMP TABLE

drop table if exists #Percent_Population_Vaccinated
create table #Percent_Population_Vaccinated
(continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccination numeric,
Rolling_People_Vaccinated numeric
)

insert into #Percent_Population_Vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location, 
dea.date) as Rolling_People_Vaccinated
from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date

select *, (Rolling_People_Vaccinated/population)*100 as Vaccination_Percentage
from #Percent_Population_Vaccinated

-- Membuat View untuk Menyimpan data yang akan divisualisasikan

create view Percent_Population_Vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location, 
dea.date) as Rolling_People_Vaccinated
from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from Percent_Population_Vaccinated