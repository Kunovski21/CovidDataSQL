select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Show likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

select Location, date,  population,total_cases, (total_cases/population)*100 as PopulationPercentage
from PortfolioProject..CovidDeaths$
where location like '%states'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states'
group by Location, population
order by PercentPopulationInfected desc

--Showing the Countries with the Highest Death Count per Population
select Location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states'
where continent is not null
group by Location
order by TotalDeathCount desc


--Let's break things down by Continent

--Showing continents with the Highest Death Count per population

select continent, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global numbers

select  sum(new_cases) as total_cases , sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%states'
where continent is not null 
--group by date
order by 1,2


--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
, 
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
	on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
	on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp table
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
	on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
	on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated