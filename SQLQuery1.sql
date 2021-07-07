select *
from portfolio1..['covid deaths$']
order by 3,4

select *
from Portfolio1..['covid vaccinations']
order by 3,4

select location,date,population,total_cases,new_cases,total_deaths
from portfolio1..['covid deaths$']
order by 1,2

-- percentage of death from total cases

select location,date,population,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
from portfolio1..['covid deaths$']
order by 1,2

-- death rate in Canada

select location,date,population,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
from portfolio1..['covid deaths$']
where location like 'canada'
order by 1,2

-- total cases vs population
select location,date,total_cases,population, (total_cases/population)*100 as infected_percentage
from portfolio1..['covid deaths$']
where location like 'canada'
order by 1,2

-- countries with highest infection rate
select location, max(total_cases) as max_total_cases,population, max((total_cases/population))*100 as infected_percentage
from portfolio1..['covid deaths$']
group by location,population
order by infected_percentage desc

--countries with highest death count
select location, max(cast(total_deaths as int)) as max_total_deaths, population
from portfolio1..['covid deaths$']
where continent is not null
group by location,population
order by max_total_deaths desc

--continents with highest death count
select location, max(cast(total_deaths as int)) as max_total_deaths, population, (max(cast(total_deaths as int))/population)*100 as death_rate
from portfolio1..['covid deaths$']
where continent is null
group by location,population
order by max_total_deaths desc

-- cases per day globally
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths
from portfolio1..['covid deaths$']
where continent is not null
group by date
order by date

-- joining covid deaths and covid vaccination tables

select *
from Portfolio1..['covid deaths$'] as dea
inner join Portfolio1..['covid vaccinations'] as vac
on dea.location=vac.location
;

-- total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Portfolio1..['covid deaths$'] as dea
inner join Portfolio1..['covid vaccinations'] as vac
on dea.location=vac.location
where dea.continent is not null
order by 1,2,3
;

-- rolling count for number of people vaccinated by date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinations
from Portfolio1..['covid deaths$'] as dea
inner join Portfolio1..['covid vaccinations'] as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3
;

--creating CTE to find % of people vaccinated by date

with PopulationVsVaccination (continent, location, date, population, new_vaccinations, rolling_people_vaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinations
from Portfolio1..['covid deaths$'] as dea
inner join Portfolio1..['covid vaccinations'] as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rolling_people_vaccinations/population)*100
from PopulationVsVaccination
order by 2,3

--creating a table to find % of people vaccinated by date

drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rolling_people_vaccinations numeric
)

insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinations
from Portfolio1..['covid deaths$'] as dea
inner join Portfolio1..['covid vaccinations'] as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select *, (rolling_people_vaccinations/population)*100
from PercentPopulationVaccinated
order by 2,3

--creating view
create view deathratecontinent as
select location, max(cast(total_deaths as int)) as max_total_deaths, population, (max(cast(total_deaths as int))/population)*100 as death_rate
from portfolio1..['covid deaths$']
where continent is null
group by location,population

create view percentpopvacc as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinations
from Portfolio1..['covid deaths$'] as dea
inner join Portfolio1..['covid vaccinations'] as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select * 
from deathratecontinent
