--Select * 
--From PortfolioProject..['covid-deaths$']
--order by 3,4

--Select * 
--From PortfolioProject..['covid-deaths$']
--order by 3,4

-- Select Data that we are goint to be using

--Select Location, date, total_cases, new_cases, total_deaths, population
--From PortfolioProject..['covid-deaths$']
--order by 1,2
-----------------------------------------------------------------------------------------------------------------------
-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

--Select Location, date, total_cases, Total_deaths, (CONVERT(float, total_deaths) / Nullif(Convert(float, total_cases), 0))*100 as DeathPercentage

--From PortfolioProject..['covid-deaths$']

--Where location like '%states%'
--order by 1,2
---------------------------------------------------------------------------------------------------------------------------
-- Looking at Total Cases vs Population

--Select Location, date, population, total_cases, (CONVERT(float, total_cases) / Nullif(Convert(float, population), 0))*100 as PercentageOfPopulationInfected

--From PortfolioProject..['covid-deaths$']

--Where location like '%states%'
--order by 1,2

-------------------------------------------------------------------------------------------------------------------------------

-- Looking at Countries with highest Infection Rate Compared to Population

--Select location, Population, Max(total_cases) as HighestInfectionCount, Max(((Convert(float, total_cases)/Nullif(Convert(float,population), 0)))) *100 as PercentPopulationInfected
--From PortfolioProject..['covid-deaths$']
--Where location like '%states%'
--Group by location, population
--order by PercentPopulationInfected desc
---------------------------------------------------------------------------------------------------------------------
--Showing highest death count by location

--Select location, Max(cast(total_deaths as int)) as TotalDeathCount
--From PortfolioProject..['covid-deaths$']
--Where continent is not null
--Group by location
--order by TotalDeathCount desc

------------------------------------------------------------------------------------------------------
-- Breaking Down by continent

--Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
--From PortfolioProject..['covid-deaths$']
--Where continent is not null
--Group by continent
--order by TotalDeathCount desc

------------------------------------------------------------------------------------------------------
--Showing countries with highest death count per population

--Select location, Population, Max(total_deaths) as DeathCount, Max(((Convert(float, total_deaths)/Nullif(Convert(float,population), 0)))) *100 as PercentPopulationDeaths
--From PortfolioProject..['covid-deaths$']
--Where location like '%states%'
--Where continent is not null
--Group by location, population
--order by PercentPopulationDeaths desc

-----------------------------------------------------------------------------------------------------

--Global Numbers

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,Sum(cast(new_deaths as int))/Nullif(Sum(new_cases),0)*100 as DeathPercentage 
From PortfolioProject..['covid-deaths$']
Where continent is not null
--group by date
order by 1,2

------------------------------------------------------------------------------------------------------
-- Looking at total population vs vaccinations

SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(bigint, COALESCE(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..['covid-deaths$'] dea
JOIN 
    PortfolioProject..['covid-vaccinations$'] vac
ON 
    dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(bigint, COALESCE(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject..['covid-deaths$'] dea
    JOIN 
        PortfolioProject..['covid-vaccinations$'] vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
    -- ORDER BY dea.location, dea.date -- This can be omitted here
)
-- Here you can use SELECT to retrieve data from the CTE
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac
-- Now you can include ORDER BY
--ORDER BY location, date;
--------------------------------------------------------------------------------------------------------------
--Temp Table
-- drop table if exists 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(bigint, COALESCE(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..['covid-deaths$'] dea
JOIN 
    PortfolioProject..['covid-vaccinations$'] vac
ON 
    dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

;WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(bigint, COALESCE(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject..['covid-deaths$'] dea
    JOIN 
        PortfolioProject..['covid-vaccinations$'] vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
    -- ORDER BY dea.location, dea.date -- This can be omitted here
)
-- Here you can use SELECT to retrieve data from the CTE
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as

SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(bigint, COALESCE(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject..['covid-deaths$'] dea
    JOIN 
        PortfolioProject..['covid-vaccinations$'] vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL