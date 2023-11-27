/*Alex The Analyst youtube: https://www.youtube.com/watch?v=qfyynHBFOsM&list=PLUaB-1hjhk8H48Pj32z4GZgGWyylqv85f */


SELECT *
FROM [Portfolio Project]..CovidDeaths
order by 3,4

SELECT *
FROM [Portfolio Project]..CovidVaccinations
WHERE continent IS NOT NULL
order by 3,4

--select the data we're going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM  [Portfolio Project]..CovidDeaths
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--Shows the likelyhood of dying if you contract Covid in your country

SELECT Location, date, total_cases, total_deaths, (CONVERT(FLOAT, total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS [Death Percentage]
FROM  [Portfolio Project]..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of the population got Covid


SELECT Location, date, population, total_cases, (CONVERT(FLOAT, total_cases)/NULLIF(CONVERT(float,population),0))*100 AS [Contracted Percentage]
FROM  [Portfolio Project]..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


--What countries have the highest infection rates compared to population

SELECT Location, population, MAX(total_cases) AS [Highest Infection Count], ROUND(MAX(CONVERT(FLOAT, total_cases))/NULLIF(CONVERT(float,population),0)*100,2) AS [Contracted Percentage]
FROM  [Portfolio Project]..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY [Contracted Percentage] DESC


--Showing the courntries with the highest death count/population
SELECT Location, MAX(cast(Total_deaths as int)) as [Total Death Count]
FROM  [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY [Total Death Count] DESC


--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(cast(Total_deaths as int)) as [Total Death Count]
FROM  [Portfolio Project]..CovidDeaths
--WHERE location lik '%states%'
WHERE continent IS not NULL
GROUP BY continent
ORDER BY [Total Death Count] DESC


--Showing continents with the highest death count

SELECT continent, MAX(cast(Total_deaths as int)) as [Total Death Count]
FROM  [Portfolio Project]..CovidDeaths
--WHERE location lik '%states%'
WHERE continent IS not NULL
GROUP BY continent
ORDER BY [Total Death Count] DESC


--GLOBAL NUMBERS

SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(New_deaths as int))/SUM(New_Cases)*100 AS [Death Percentage] --total_deaths, (total_deaths/total_cases)*100 as [Death Percentage]
FROM  [Portfolio Project]..CovidDeaths
--WHERE location LIKE '%states%'
--WHERE continent IS NOT NULL AND new_deaths IS NOT NULL AND new_cases IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Total population vs vaccinations
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(CV.NEW_VACCINATIONS as float)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION, CD.DATE) AS RollingPeopleVaccinated
FROM CovidDeaths CD
JOIN CovidVaccinations CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL --and cd.location IS NOT NULL and cd.population IS NOT NULL and cv.new_vaccinations IS NOT NULL and cd.date > 2021-01-01
ORDER BY 1,2,3


--Use the above query as a CTE in order to divide by population

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(CV.NEW_VACCINATIONS as float)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION, CD.DATE) AS RollingPeopleVaccinated
FROM CovidDeaths CD
JOIN CovidVaccinations CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--Temp Table

DROP Table IF EXISTS
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(CV.NEW_VACCINATIONS as float)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION, CD.DATE) AS [RollingPeopleVaccinated]
FROM [Portfolio Project]..CovidDeaths CD
JOIN [Portfolio Project]..CovidVaccinations CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL 
--ORDER BY 2,3

SELECT *, ([RollingPeopleVaccinated]/Population)*100
FROM #PercentPopulationVaccinated



--Creating View to store data for later visualizations
USE [Portfolio Project]
GO

CREATE VIEW PercentPopulationVaccinated as 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(CV.NEW_VACCINATIONS as float)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION, CD.DATE) AS [RollingPeopleVaccinated]
FROM [Portfolio Project]..CovidDeaths CD
JOIN [Portfolio Project]..CovidVaccinations CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL 
--ORDER BY 2,3