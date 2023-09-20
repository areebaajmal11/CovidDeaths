select *
from CovidDeaths$
order by 3, 4

--select *
--from CovidVaccinations$
--order by 3, 4

--select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1, 2

-- Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As Death_percentage
from CovidDeaths$
order by 1, 2

-- change the datatype of total_cases and total_deaths to int from nvarchar so to perform division on them

ALTER TABLE CovidDeaths$
ALTER COLUMN total_cases float

ALTER TABLE CovidDeaths$
ALTER COLUMN total_deaths float

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths$
where location like '%states%'
order by 1,2

-- Looking at Total cases vs population
-- shows what % of population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as Population_Percentage
From CovidDeaths$
where location like '%states%'
order by 1,2

--Lokking at countries with highest infection rate

select location, population, MAX(total_cases) as HighestInfection, Max((total_cases/population))*100 as percentagePopulationInfected
from CovidDeaths$
--where location like '%states%'
group by location, population
order by 4 Desc

-- Showing Countries with Highest Death Count per population 

select location, MAX(total_deaths) as TotalDeathCount
from CovidDeaths$
where continent is  not null
group by location
order by TotalDeathCount desc

--lets break this down by continent

select continent, MAX(total_deaths) as TotalDeathCount
from CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--showing continent with the highest death count per population

select location, MAX(total_deaths) as TotalDeathCount
from CovidDeaths$
where continent is null
group by location
order by TotalDeathCount desc

--Global Numbers

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
where continent is not null
--group by date
order by 1,2

select *
from CovidDeaths$

select *
from CovidVaccinations$

-- Looking at Total Population Vs Vaccinations

select d.location, d.continent, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations AS bigint)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths$ d
join CovidVaccinations$ v
on d.location = v.location 
and d.date = v.date
where d.continent is not null
order by 1,3

-- Use CTE to perform calcultaion on partition by in previous querry

with PopvsVac (Continent, Location, Date, Population, New_Vaccinantion, RollingPeopleVaccinated) as
(
select top 100 percent d.location, d.continent, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations AS bigint)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths$ d
join CovidVaccinations$ v
on d.location = v.location 
and d.date = v.date
where d.continent is not null
order by 1,3
)
select  *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--Using Temp Table to perform Calculations on Partition By in previous querry

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar (255), 
location nvarchar (255),
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select top 100 percent d.location, d.continent, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations AS bigint)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths$ d
join CovidVaccinations$ v
on d.location = v.location 
and d.date = v.date
where d.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
select d.location, d.continent, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations AS bigint)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths$ d
join CovidVaccinations$ v
on d.location = v.location 
and d.date = v.date
where d.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated