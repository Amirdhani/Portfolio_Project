Select *
From PortfolioProject..CovidDeaths
Where continent is Not Null


-- Select data that we are going to be starting with
Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
Where continent is Not Null
Order by 1,2


-- Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select continent,location,date,total_deaths,new_deaths,
CAST(ROUND((CAST(total_deaths AS FLOAT) * 100.0 / CAST(total_cases AS FLOAT)), 2) AS VARCHAR) + '%' AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location Like '%states%' 
And continent is Not Null
Order by 1,2


-- Total cases Vs Total Population
-- Shows what percentage of population infected with covid
Select location,date,population,total_cases,(total_cases/population) *100 as PopulationInfected
From PortfolioProject..CovidDeaths
Where Location Like '%India%'
Order by 1,2


-- Locations with highest infection rate compared to population
Select location,population,
max(total_cases) as HighestInfectionCount,
max((total_cases/population))*100 as PercentpopulationInfected
From PortfolioProject..CovidDeaths
Group by location,population
Order by PercentpopulationInfected desc


-- Countries with highest death count per population
Select location,max(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Group by location
Order by TotalDeathCount desc


-- Breaking things down by continent
-- Showing continents with highest death count per population
Select continent,max(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is Not Null
Group by continent
Order by TotalDeathCount desc


-- Global Numbers
Select continent,
Sum(new_cases) as Total_Cases,
Sum(Cast(new_deaths as int)) as Total_Deaths,
Sum(Cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is Not Null
Group by continent
Order by 1,2


-- Total population Vs Vaccinations
-- Shows percentage of population that has received at least one covid vaccine
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations)) Over(partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location And dea.date = vac.date
Where dea.continent is Not Null
and new_vaccinations is Not Null 
Order by 2,3


-- Using CTE to perform calculation on partition by in previous query
With PopVsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations))Over(Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date
Where dea.continent is Not Null And new_vaccinations is Not Null
)
Select *,(RollingPeopleVaccinated/population)*100 as PeopleVaccinePercentage
From PopVsVac 


-- Using Temp Table to perform calculation on Partition by in previous query
Create table #PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date dateTime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select d.continent,d.location,d.date,d.population,v.new_vaccinations,
Sum(Convert(int,v.new_vaccinations))Over(Partition by d.location Order by d.location,d.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
On d.location = v.location and d.date = v.date

Select *,(RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated
Where New_Vaccinations is Not Null


-- Creating view to store data for later visualizations
DROP VIEW IF EXISTS PercentPopulationVaccinated;

Create View PercentPopulationVaccinated as
Select d.continent,d.location,d.date,d.population,v.new_vaccinations,
Sum(Convert(int,v.new_vaccinations))Over(Partition by d.location Order by d.location,d.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
On d.location = v.location and d.date = v.date
Where d.continent is Not Null and v.new_vaccinations is Not Null

Select * 
From PercentPopulationVaccinated
