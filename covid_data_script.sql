-- Infection Rate by Country
SELECT location, population, MAX(total_cases) AS MaxTotal, Max((total_cases / population)) * 100 AS infected_percentage
FROM PortfolioProject.dbo.covid_deaths
GROUP BY location, population
ORDER BY infected_percentage DESC


-- Death Count by Country
SELECT location, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject.dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC


-- Death Rate by Country
SELECT location, (MAX(cast(total_deaths as int)) / MAX(total_cases))  * 100 AS death_rate
FROM PortfolioProject.dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY death_rate DESC


-- Global Death Rate
SELECT SUM(new_cases) AS total_cases
		, SUM(CAST(new_deaths AS int)) AS total_death_count
		, SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS death_percentage
FROM PortfolioProject.dbo.covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Population vs Vaccinations
WITH population_vac (continent, location, date, population, new_vaccinations, total_vaxxed)
AS
(
	SELECT death.continent
		, death.location
		, death.date
		, death.population
		, vac.new_vaccinations
		, SUM(CAST(vac.new_vaccinations AS INT)) 
			OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS total_vaxxed
	FROM PortfolioProject.dbo.covid_deaths death
	JOIN PortfolioProject.dbo.covid_vaccinations vac
		ON death.location = vac.location
		AND death.date = vac.date
	WHERE death.continent IS NOT NULL
)
SELECT *, (total_vaxxed / population) * 100
FROM population_vac


-- Creating View for Tableau Visualization
CREATE VIEW PopulationVaxxedPercentage AS 
SELECT death.continent
		, death.location
		, death.date
		, death.population
		, vac.new_vaccinations
		, SUM(CAST(vac.new_vaccinations AS INT)) 
			OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS total_vaxxed
FROM PortfolioProject.dbo.covid_deaths death
JOIN PortfolioProject.dbo.covid_vaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL