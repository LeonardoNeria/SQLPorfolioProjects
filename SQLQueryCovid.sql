SELECT *
FROM PortfolioProjectSQL1..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3, 4

SELECT *
FROM PortfolioProjectSQL1..CovidVaccinations$
ORDER BY 3, 4

--- Select data to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjectSQL1..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY location, date

--- Looking total cases vs Total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS DeathPercentage
FROM PortfolioProjectSQL1..CovidDeaths$
WHERE location LIKE '%mexico%'
ORDER BY location, date

--- Looking at Total cases vs Population
--- Shows what percentage of population got covid

SELECT
    location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProjectSQL1..CovidDeaths$
WHERE location LIKE '%mexico%'
ORDER BY location, date


--- Looking at countries with highest infection rates compared to population 

SELECT
    location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProjectSQL1..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--- Looking at countries with highest death count per population

SELECT
    location,
	MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProjectSQL1..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--- highest death count per continent

SELECT
    location,
	MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProjectSQL1..CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT
    continent,
	MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProjectSQL1..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--- Global numbers

SELECT
    date,
	SUM(new_cases) AS NewCases,
	SUM(CAST(new_deaths AS int)) AS NewDeaths,
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProjectSQL1..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, NewCases

--- Using Covid vaccinations table now and use join function

SELECT *
FROM PortfolioProjectSQL1..CovidDeaths$ AS de
INNER JOIN PortfolioProjectSQL1..CovidVaccinations$ AS vac
    ON de.location = vac.location AND de.date = vac.date
WHERE de.continent IS NOT NULL AND vac.continent IS NOT NULL

--- Looking at Total population vs Vaccinations

SELECT
    de.continent,
	de.location,
	de.date,
	de.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY de.location ORDER BY de.location, de.date) AS PeopleVaccinated
FROM PortfolioProjectSQL1..CovidDeaths$ AS de
INNER JOIN PortfolioProjectSQL1..CovidVaccinations$ AS vac
    ON de.location = vac.location 
	AND de.date = vac.date
WHERE de.continent IS NOT NULL
ORDER BY 2,3


--- USE CTE 

WITH PopvsVac (continent, location, date, population, new_vaccinations, PeopleVaccinated)
AS
(
SELECT
    de.continent,
	de.location,
	de.date,
	de.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY de.location ORDER BY de.location, de.date) AS PeopleVaccinated
FROM PortfolioProjectSQL1..CovidDeaths$ AS de
INNER JOIN PortfolioProjectSQL1..CovidVaccinations$ AS vac
    ON de.location = vac.location 
	AND de.date = vac.date
WHERE de.continent IS NOT NULL
)
SELECT *, (PeopleVaccinated/population)*100 AS PercentageVaccination
FROM PopvsVac

--- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated

(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
PeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT
    de.continent,
	de.location,
	de.date,
	de.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY de.location ORDER BY de.location, de.date) AS PeopleVaccinated
FROM PortfolioProjectSQL1..CovidDeaths$ AS de
INNER JOIN PortfolioProjectSQL1..CovidVaccinations$ AS vac
    ON de.location = vac.location 
	AND de.date = vac.date
WHERE de.continent IS NOT NULL

SELECT *, (PeopleVaccinated/population)*100 AS PercentageVaccination
FROM #PercentPopulationVaccinated

--- Create View

CREATE VIEW PercentagePopulationVaccinated

AS

SELECT
    de.continent,
	de.location,
	de.date,
	de.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY de.location ORDER BY de.location, de.date) AS PeopleVaccinated
FROM PortfolioProjectSQL1..CovidDeaths$ AS de
INNER JOIN PortfolioProjectSQL1..CovidVaccinations$ AS vac
    ON de.location = vac.location 
	AND de.date = vac.date
WHERE de.continent IS NOT NULL

SELECT *
FROM PercentagePopulationVaccinated