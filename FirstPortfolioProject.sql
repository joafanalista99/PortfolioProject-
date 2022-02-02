SELECT *
FROM PortfolioProject..CovidDeaths
WHERE CONTINENT IS NULL
ORDER BY 3,4


SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- DATA EXPLORATION 

SELECT location, date, population, total_cases, new_cases, total_deaths 
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

    -- LETHALITY (total_deaths/total_cases)	

SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS lethality
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Portugal%'           -- I COULD INSERT OTHER COUNTRIES (LOCATIONS)
ORDER BY 1,2

      -- Percent Infection by date

SELECT location, date, population, total_cases, (total_cases/population)*100 AS percentage_infection
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Portugal%'           
Order by 2

       -- Percentage of Infections (Total numbers)

SELECT location,population, MAX(total_cases) as totalcases, (MAX(total_cases)/population)*100 AS percentage_infections_total
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL   -- When the Continent is null, the continents appear on the location column
AND total_cases IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

        -- Total death count

SELECT location, MAX(CAST (total_deaths AS INT)) AS  TotalDeathCount -- CAST totaldeaths as int because the data type is nvarchar(255)
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC

       -- Total Deaths per capita 

SELECT location, population,  MAX(CAST(total_deaths AS INT)) AS totaldeaths, (MAX(CAST(total_deaths AS INT))/population) * 100 AS deaths_percapita 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location, population
HAVING (MAX(total_deaths)/population) * 100 IS NOT NULL
ORDER BY 4 DESC

       -- DATA FROM CONTINENT(Total Cases)
SELECT continent, MAX(total_CASES) 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent       -- FOR SOME REASON I DON'T GET THE CORRECT NUMBERS SELECTING CONTINENT

SELECT location, MAX (total_cases) as totalcases
FROM PortfolioProject..CovidDeaths
WHERE CONTINENT IS NULL 
GROUP BY location       -- THE NUMBERS ARE CORRECT IN THIS WAY

--DATA FROM WORLD

SELECT location, MAX(total_cases) as totalcases, MAX(CAST(total_deaths AS INT)) AS totaldeaths
FROM PortfolioProject..CovidDeaths 
WHERE location = 'World'
GROUP BY location


SELECT location, date, SUM(new_cases) AS casesbydate_world, SUM(CAST (new_deaths AS INT)) AS deathsbydate_world , (SUM(CAST (new_deaths AS INT))/SUM(new_cases))*100 AS deathpercent
FROM PortfolioProject..CovidDeaths
WHERE location = 'World'  AND new_cases <> 0
GROUP BY location, date
ORDER BY 2


-- Join the tables
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as total_administered_vaccines, people_fully_vaccinated 
FROM PortfolioProject..CovidDeaths AS dea
INNER JOIN PortfolioProject..[CovidVaccinations ] AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND dea.location = 'Portugal'

--CTE TABLE

WITH PopvsVac (continent, location, date , population, new_vaccinations,total_administered_vaccines, people_fully_vaccinated)
AS
(
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as total_administered_vaccines, people_fully_vaccinated 
FROM PortfolioProject..CovidDeaths AS dea
INNER JOIN PortfolioProject..[CovidVaccinations ] AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND dea.location = 'Portugal'

)
SELECT *, (people_fully_vaccinated/population)*100  AS percent_of_people_fullyvaccinated
FROM PopvsVac



CREATE VIEW InfectionNumbersByDate AS
SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS lethality
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Portugal%'           -- I COULD INSERT OTHER COUNTRIES (LOCATIONS)
--ORDER BY 1,2

CREATE VIEW TOTALDEATHS AS
SELECT location, population,  MAX(CAST(total_deaths AS INT)) AS totaldeaths, (MAX(CAST(total_deaths AS INT))/population) * 100 AS deaths_percapita 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location, population
HAVING (MAX(total_deaths)/population) * 100 IS NOT NULL
--ORDER BY 4 DESC

CREATE VIEW CONTINENTDATA AS
SELECT location, MAX (total_cases) as totalcases
FROM PortfolioProject..CovidDeaths
WHERE CONTINENT IS NULL 
GROUP BY location