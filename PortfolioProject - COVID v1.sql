-- This is an Exploratory Data Analysis (EDA) Project on COVID-19 Cases, Deaths and Vaccinations
-- Data Source - Our world in Data (owid)
-- Period Covered February 2020 to November 25, 2021



-- General Overview of the 'Deaths' Table

select *
from CovidDeaths
where continent IS NOT NULL
order by 3, 4


-- Select Data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1, 2

-- Looking at Total cases vs. Total Deaths
-- shows the likelihood of death in the event of getting infected with COVID, by country
-- Drill down to Canada

select Location, date, total_cases, total_deaths, (total_deaths/(total_cases*1.00))* 100  as DeathPercentage
from CovidDeaths
where location = 'canada'
order by 1, 2

--gives 29,655 deaths as at 25 Nov 2021, date of this analysis. Very Accurate according to values on Google


--Looking at Total Cases vs Population
-- Shows what percentage of population got infected by COVID

select Location, date, total_cases, population, (total_cases/(population*1.00))* 100  as InfectionPercentage
from CovidDeaths
where location = 'canada'
order by 1, 2


-- Looking at Countries with Highest Infection Rates compared to Population

select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/(population*1.00)))* 100  as PercentPopulationInfected
from CovidDeaths
--where location like '%canada'
group by location, population
order by 4 desc

--Some of the most surprising results. Montenegro, Seychelles and Andorra having the Top3 highest population Infected as a 
--percentage of Population


-- showing Countries with Highest Death Count Per Population

select Location, MAX(total_deaths) as Total_DeathCount
from CovidDeaths
--where location like '%canada'
where continent is not null
group by continent, location
order by 2 desc


-- LET'S BREAK THINGS DOWN BY CONTINENT - DeathCount by Continent
-- Showing Continents with the highest death count per population

select continent, MAX(total_deaths) as Total_DeathCount
from CovidDeaths
--where location like '%canada'
where continent is not null
group by continent
order by 2 desc

-- GLOBAL NUMBERS
-- Numbers by date

select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases*1.00)* 100  as DeathPercentage
from CovidDeaths
--where location like '%canada'
where continent is not null
group by date
order by 1, 2


-- Overrall, across the world...
--what is the death percentage?

select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases*1.00)* 100  as DeathPercentage
from CovidDeaths
--where location like '%canada'
where continent is not null
--group by date
order by 1, 2

-- TAKING A LOOK AT THE Vaccinations TABLE

select *
from CovidVaccinations


-- Joining the two tables for more insights

select *
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


-- Looking at Total Population vs Vaccinations

-- First Option - USE CTE

WITH  PopvsVac as (

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_VacCount
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--where location = 'Canada'
)
select continent, location, date, population, new_vaccinations, Rolling_People_VacCount, (Rolling_People_VacCount/(population *1.00))* 100 as 
Rolling_VacCount_Percent
from PopvsVac
order by 2, 3


-- Option 2
-- USE Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_VacCount numeric
)

INSERT INTO #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_VacCount
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--where location = 'Canada'

Select *, (Rolling_People_VacCount/(population *1.00))* 100 as Rolling_VacCount_Percent
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated
AS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_VacCount
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--where location = 'Canada'


Select *
from PercentPopulationVaccinated

-- Visualizations done in Tableau Public