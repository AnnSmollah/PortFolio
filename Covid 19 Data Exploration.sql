
/*
Covid 19 Data Exploration 

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT*
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT*
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--Select data to use

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order By 1,2

--Looking at Total Cases vs Total Deaths
---First convert the data type of "total_deaths" and "total_cases" columns to a numeric data type such as FLOAT or DECIMAL before performing the division

SELECT location, date, total_deaths, total_cases, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 AS death_rate_percentage
FROM PortfolioProject..CovidDeaths
ORDER BY location, date;

--Shows likelihood of dying if you contract Covid in your county
---Kenya
SELECT location, date, total_deaths, total_cases, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 AS death_rate_percentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'kenya'
ORDER BY location, date;

---Unite States
SELECT location, date, total_deaths, total_cases, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 AS death_rate_percentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
ORDER BY location, date;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, Population, total_cases, (total_cases/Population )*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like 'Kenya'
ORDER BY location, date;

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like 'Kenya'
Group by Location, Population
order by PercentPopulationInfected desc
--order by PercentPopulationInfected asc


-- Countries with Highest Death Count per Population

Select Location, MAX(Cast(Total_deaths as int)) as Totaldeathcount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, Population
order by Totaldeathcount desc

--Breaking data by continent 
--Showing continents with the hieghest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Kenya%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like 'Kenya'
where continent is not null 
order by 1,2


-- Total Population vs Vaccinations
-- Showing Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--CTE
-- Using CTE to perform Calculation on Partition By in previous query

with povvsvac(continent, location , date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select*, (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercentage
from povvsvac

--Temp Table
-- Using Temp Table to perform Calculation on Partition By in previous query

--Create a Temp Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

DROP Table if exists #PercentPopulationVaccinated

--Views
-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select*
from PercentPopulationVaccinated

