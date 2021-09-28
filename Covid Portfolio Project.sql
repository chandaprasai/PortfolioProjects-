SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
order by 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4
-- Select Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths 
-- Shows likelihood of dying if you contract covid in your country 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2


-- Looking at the total cases vs population 
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--WHERE location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population 
SELECT location,population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location,population 
order by PercentPopulationInfected desc

-- Showing countries with highest death count per population 

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null 
GROUP BY location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT 

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null 
GROUP BY continent 
order by TotalDeathCount desc



-- LET'S BREAK THINGS DOWN BY CONTINENT 
-- Showing the continents with the highest death count 
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null 
GROUP BY continent 
order by TotalDeathCount desc

-- GLOBAL NUMBERS 

SELECT  SUM (new_cases) as total_cases, SUM (cast(new_deaths  as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null 
--GROUP BY date 
order by 1,2

--Looking at Total Population vs Vaccinations 
--USE CTE 
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated )
as
(
Select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location= vac.location
and dea.date= vac.date
WHERE dea.continent is not null
--ORDER by 2,3
)
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--Temp table 
DROP table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric 
)

Insert Into #PercentPopulationVaccinated
Select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location= vac.location
and dea.date= vac.date
--WHERE dea.continent is not null
--ORDER by 2,3

SELECT * , (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visalizations 

Create view PercentPopulationVaccinated as 
Select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location= vac.location
and dea.date= vac.date
WHERE dea.continent is not null
--ORDER by 2,3






