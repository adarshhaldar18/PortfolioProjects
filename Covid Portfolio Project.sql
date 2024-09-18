SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4


SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--Select Data That we are going to be using

SELECT location , date , total_cases , new_cases , total_deaths , population
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

--Looking at Total Cases Vs Total Deaths

SELECT location,date,total_cases,total_deaths,new_cases,(total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%india%'
AND continent is NOT NULL
ORDER BY 1,2

--Looking at total cases vs populations
--Shows what percentage of population got covid
SELECT location , date ,population,total_cases, (total_cases/population) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE --location like '%states%'
continent is NOT NULL
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate Compared to Populaton
SELECT location , population ,MAX(total_cases) AS HighestInfectedCount, MAX(total_cases)/(population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location , population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with highest death count per population
SELECT location ,MAX(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCounts DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--global numbers
SELECT SUM(new_cases) AS TotalCases,SUM(cast(new_deaths as int)) AS TotalDeaths ,SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
--ORDER BY 1,2

--Joining the deaths and vaccination tables both
SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
AND dea.date = vac.date

--Total Population vs Vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT dea.continent ,dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--Using CTE to cdo calculations over previous query
WITH popsvsvac (Continent,Location,Date,Population,New_vaccination,RollingPeopleVacinated)
AS
(
SELECT dea.continent ,dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVacinated/Population)*100 AS VaccinatedPercent
FROM popsvsvac


--TEMP TABLE


Drop table if exists #PERCENTPOPULATIONAFFECTED
Create table #PERCENTPOPULATIONAFFECTED
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccination numeric,
RollingPeopleVacinated numeric
)

Insert into #PERCENTPOPULATIONAFFECTED
SELECT dea.continent ,dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *,(RollingPeopleVacinated/Population)*100 AS VaccinatedPercent
FROM #PERCENTPOPULATIONAFFECTED

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

SELECT *
FROM PercentPopulationVaccinated
