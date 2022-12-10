select * from Portfolio.dbo.coviddeaths
where continent is not null
order by 3,4

/*
select * from Portfolio.dbo.covidvaccinations
order by 3,4
*/

--Lets select data that we are going to use

select location, date, total_cases,new_cases, total_deaths, population from Portfolio..coviddeaths
where continent is not null
order by 1,2

--Looking at the Total Cases vs Total Deaths (percentage)
--shows the likelihood fo dying if someone contract covid in their country

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage from Portfolio..coviddeaths
where location like '%india%'
--where continent is not null
order by 1,2


--Looking at the Total Cases vs Population
--shows % of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as percentofpopulationinfected from Portfolio..coviddeaths
where location like '%india%'
--where continent is not null
order by 1,2


--Looking at countries with Highest Infection Rate compared to population


select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
percentofpopulationinfected from Portfolio..coviddeaths
--where location like '%india%'
Group by location,population
order by percentofpopulationinfected desc



select location, population,date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
percentofpopulationinfected from Portfolio..coviddeaths
--where location like '%india%'
Group by location,population,date
order by percentofpopulationinfected desc


--Lets take a look at countries with Highest Death count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio..coviddeaths
--where location like '%india%'
where continent is not null
Group by location
order by TotalDeathCount desc


--NOW LETS BREAK ACCORDING TO CONTINENTS

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio..coviddeaths
--where location like '%india%'
where continent is null
Group by location
order by TotalDeathCount desc

--^^above way is correct way for most accurate results



--Showing the continents with the Highest death Count

--as above




--Global Numbers accross the world

select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Portfolio..coviddeaths
--where location like '%india%'
where continent is not null
Group by date
order by 1,2

--overall

select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Portfolio..coviddeaths
--where location like '%india%'
where continent is not null
--Group by date
order by 1,2


-- LOOKING AT NOW VACCINATION DATA ALSO

Select * 
from portfolio..coviddeaths dea
Join Portfolio..covidvaccinations vac
  On dea.location=vac.location
  and dea.date=vac.date


--looking at Total Population Vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeoplevaccinated
--(RollingPeoplevaccinated/population)*100
from portfolio..coviddeaths dea
Join portfolio..covidvaccinations vac
  On dea.location=vac.location
  and dea.date=vac.date
where dea.continent is NOT NULL
order by 2,3


--USE CTE

--with Population vs Vaccination
With PopvsVac (Continent, Location, Date,Population,New_vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeoplevaccinated
--,(RollingPeoplevaccinated/population)*100
from portfolio..coviddeaths dea
Join portfolio..covidvaccinations vac
  On dea.location=vac.location
  and dea.date=vac.date
where dea.continent is NOT NULL
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac
--^^ this tells about what % of population in country is vaccinated


--TEMP table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeoplevaccinated/population)*100
from portfolio..coviddeaths dea
Join portfolio..covidvaccinations vac
  On dea.location=vac.location
  and dea.date=vac.date
--where dea.continent is NOT NULL
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--creating VIEW for later Data Visualization

CREATE VIEW PercentPopulationVaccinated AS 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeoplevaccinated/population)*100
from portfolio..coviddeaths dea
Join portfolio..covidvaccinations vac
  On dea.location=vac.location
  and dea.date=vac.date
where dea.continent is NOT NULL
--order by 2,3

select * 
from PercentPopulationVaccinated



--For Tableau public insights with visualizations
--1 for Tableau
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Portfolio..coviddeaths
--where location like '%india%'
where continent is not null
--Group by date
order by 1,2


--2 for Tableau
SELECT location, SUM(cast(new_deaths as bigint)) as TotalDeathCount
FROM Portfolio..coviddeaths
WHERE continent is NULL
and location not in ('World','European Union','International')
Group by location
order by TotalDeathCount desc


--3 for Tablaeu Table
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
percentofpopulationinfected from Portfolio..coviddeaths
--where location like '%india%'
Group by location,population
order by percentofpopulationinfected desc


--4 for Tablaeu Table
select location, population,date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
percentofpopulationinfected from Portfolio..coviddeaths
--where location like '%india%'
Group by location,population,date
order by percentofpopulationinfected desc
