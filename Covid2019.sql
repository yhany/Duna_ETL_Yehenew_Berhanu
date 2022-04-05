select * from [dbo].[CovidDeaths]
order by 3,4
-----
--select * from [dbo].[CovidVaccinated]
--order by 3,4

----select data that we are going to use 
select location, date,total_cases, new_cases,  total_deaths,population from [dbo].[CovidDeaths]
order by 1,2

----Looking at how many total cases and how many people death

select location, date,total_cases ,total_deaths,(total_deaths/total_cases)*100 as DeathsPercentage from [dbo].[CovidDeaths]
where location like '%Ethiopia%'
order by 1,2

----Looking at Total cases and populations 
---showe what percentage of the population got covid 
select location, date,population,total_cases ,total_deaths,(total_cases/population)*100 as PercentageOFPopulation from [dbo].[CovidDeaths]
--where location like '%Ethiopia%'
order by 1,2

---Looking at countries with highest infection rate compared to population 
select location,population,Max(total_cases) as HighestInfection, MAx((total_cases/population))*100 as PercentageOFPopulation from [dbo].[CovidDeaths]
--where location like '%Ethiopia%'
group by location,population
order by PercentageOFPopulation desc

-----Showing countries with highest death count per poputaltion
select location,MAx(cast( total_deaths as int)) as TotalDeaths from [dbo].[CovidDeaths]
where location is not null
group by location
order by TotalDeaths desc
---Showing countries with highest death count per poputaltion and breakdown by continent 
select continent,MAx(cast( total_deaths as int)) as TotalDeaths from [dbo].[CovidDeaths]
where continent is not null
group by continent
order by TotalDeaths desc

----Golbale Number
select date, sum(new_cases) as totalCases,sum(cast(new_deaths as int))*100 as TotalDeaths 
, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [dbo].[CovidDeaths]
where continent is not null
group by date
order by 1,2
-----Total death in the world
select sum(cast (new_cases as int)) as totalCases,sum(cast(new_deaths as int))*100 as TotalDeaths 
, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [dbo].[CovidDeaths]
where continent is not null
---group by date
order by 1,2

Select  Dea.continent, Dea.location, Dea.Date, Dea.population ,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVacinated
 
 from [dbo].[CovidDeaths] Dea
join CovidVaccinated Vac 
on Vac.date= Dea.date and vac.location=dea.location
where dea.continent is not null
order by 2,3

----useing CTE table and get RollingPeopleVacinated by percentage divided by vacinated 
--create cte and find out how many rollingpoeplevacinated from populstion 

with PopulationVaccin (continent,location,Date,population,new_vaccinations,RollingPeopleVacinated)
as
(Select  Dea.continent, Dea.location, Dea.Date, Dea.population ,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVacinated
 --,(RollingPeopleVacinated/population)*100
 from [dbo].[CovidDeaths] Dea
join CovidVaccinated Vac 
on Vac.date= Dea.date and vac.location=dea.location
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVacinated/population)*100 as Percentagebypopulaion 
from PopulationVaccin

-----create tab table and save into sql server to ues for reporting 

drop table if  exists  #PercentagePopulationVaccinated
go
create table #PercentagePopulationVaccinated
(
continent nvarchar (225),
location  nvarchar(225), 
Date datetime, 
population numeric ,
new_vaccinations numeric,
RollingPeopleVacinated numeric
)
insert into #PercentagePopulationVaccinated
Select  Dea.continent, Dea.location, Dea.Date, Dea.population ,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVacinated
 --,(RollingPeopleVacinated/population)*100
 from [dbo].[CovidDeaths] Dea
join CovidVaccinated Vac 
on Vac.date= Dea.date and vac.location=dea.location
--where dea.continent is not null
--order by 2,3
select * ,(RollingPeopleVacinated/population)*100 as Percentagebypopulaion
from #PercentagePopulationVaccinated


----creating view for visualazation reports
drop view if exists vPopulationVaccinated
go
create view  vPopulationVaccinated 
AS
Select  Dea.continent, Dea.location, Dea.Date, Dea.population ,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVacinated
 
 from [dbo].[CovidDeaths] Dea
join CovidVaccinated Vac 
on Vac.date= Dea.date and vac.location=dea.location
where dea.continent is not null
--order by 2,3
select *from  vPopulationVaccinated