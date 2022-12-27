SELECT *
  FROM covid..covid_vacc
  ORDER by 3, 4;

SELECT *
 FROM covid..covid_deaths
  ORDER by 3, 4;

-- Select the data I will use
SELECT Location, date, Total_cases, new_cases, total_deaths, population
 FROM covid..covid_deaths
  ORDER by 1, 2;

-- Looking at Total Cases Vs Total Deaths
-- Shows what percentage of the population has COVID

SELECT Location, date, Total_cases, new_cases, total_deaths, (Total_deaths/total_cases)*100 AS Percentofpopinfected
 FROM covid..covid_deaths
 WHERE location like '%states%' OR location like '%NIGERIA%'
  ORDER by 1, 2;

 -- Looking at Countries with Highest Infection Rate compared to Population
 SELECT Location, Population, Max(Total_cases) AS HighestInfionCount, MAX((Total_deaths/total_cases))*100 AS Percentofpopinfected
 FROM covid..covid_deaths
 -- WHERE location like '%states%' OR location like '%NIGERIA%'
 GROUP By Location, Population
 ORDER by 4 DESC;

 -- BREAKING DOWN BY CONTINENT
SELECT continent, Max(cast(Total_deaths as int)) AS TotalDeathCount
 FROM covid..covid_deaths
 -- WHERE location like '%states%' OR location like '%NIGERIA%'
 WHERE continent is not null
 GROUP By continent 
 ORDER by 2 DESC;


 --Showing Countries with Highest Death count per Population
SELECT Location, Max(cast(Total_deaths as int)) AS TotalDeathCount
 FROM covid..covid_deaths
 -- WHERE location like '%states%' OR location like '%NIGERIA%'
 WHERE continent is null
 GROUP By Location 
 ORDER by 2 DESC;


  -- GLOBAL NUMBERS
SELECT  sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
 FROM covid..covid_deaths
 -- WHERE location like '%states%' OR location like '%NIGERIA%'
 WHERE continent is not null
-- GROUP By date 
 ORDER by 1, 2 DESC;
-- This shows that we have about 1% death rate.




-- Using the Vaccination Data JOIN with deaths
-- Looking at the total population that has been vaccinated
SELECT D.continent, D.location, D.date, D. population, V.new_vaccinations, SUM(CONVERT(INT, V.new_vaccinations)) OVER(Partition by D.Location ORDER BY D.Location, D.date) AS RollingPeopleVaccinated
  FROM covid..covid_deaths D
		JOIN
	covid..covid_vacc V ON D.location = V.location AND D.date = V.date
	WHERE D. continent is not null
	ORDER BY 2,3
  

 -- USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT D.continent, D.location, D.date, D. population, V.new_vaccinations, SUM(CONVERT(INT, V.new_vaccinations)) OVER(Partition by D.Location ORDER BY D.Location, D.date) AS RollingPeopleVaccinated
  FROM covid..covid_deaths D
		JOIN
	covid..covid_vacc V ON D.location = V.location AND D.date = V.date
	WHERE D. continent is not null
	--ORDER BY 2,3
	)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location  nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT D.continent, D.location, D.date, D. population, V.new_vaccinations, SUM(CONVERT(BIGINT, V.new_vaccinations)) OVER(Partition by D.Location ORDER BY D.Location, D.date) AS RollingPeopleVaccinated
  FROM covid..covid_deaths D
		JOIN
	covid..covid_vacc V ON D.location = V.location AND D.date = V.date
	--WHERE D. continent is not null
	--ORDER BY 2,3

SELECT (RollingPeopleVaccinated/Population)*100
FROM tempdb.dbo.#PercentPopulationVaccinated




-- CREATING VIEW TO STORE FOR LATER VISUALISATION
CREATE  VIEW PercentPopulationVaccinated AS 
SELECT D.continent, D.location, D.date, D. population, V.new_vaccinations, SUM(CONVERT(INT, V.new_vaccinations)) OVER(Partition by D.Location ORDER BY D.Location, D.date) AS RollingPeopleVaccinated
  FROM covid..covid_deaths D
		JOIN
	covid..covid_vacc V ON D.location = V.location AND D.date = V.date
	WHERE D. continent is not null
	--ORDER BY 2,3


SELECT TOP (1000) *
  FROM [master].[dbo].[PercentPopulationVaccinated]
