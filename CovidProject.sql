SELECT *
FROM PortfolioProject.dbo.coviddeaths
order by 3,4;

--SELECT *
--FROM PortfolioProject.dbo.covidvaccinations
--order by 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.coviddeaths
ORDER BY 1,2;

--Looking at total cases vs. total deaths
--Shows likelihood of dying if you contract Covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
FROM PortfolioProject.dbo.coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

--Looking at total cases vs. population
--Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS percentpopulationinfected
FROM PortfolioProject.dbo.coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

--Looking at countries with highest infection rate

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS percentpopulationinfected
FROM PortfolioProject.dbo.coviddeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY percentpopulationinfected desc;

--Showing Countries with highest death count

Select location, max(cast(total_deaths as int)) as totaldeathcount
From portfolioproject.dbo.coviddeaths
where continent is not null
group by location
order by totaldeathcount desc;

--Let's break things down by continent

Select location, max(cast(total_deaths as int)) as totaldeathcount
From portfolioproject.dbo.coviddeaths
Where continent is null
group by location
order by totaldeathcount desc;

--Showing continents with their respective highest individual country death counts

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.coviddeaths
WHERE continent is not null
Group by continent
order by totaldeathcount desc;

--Global numbers

SELECT sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 AS deathpercentage
FROM PortfolioProject.dbo.coviddeaths
where continent is not null;

--Looking at total population vs. vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as rolling_vaccination_total, (rolling_vaccination_total/dea.population)*100
From PortfolioProject..coviddeaths dea
Left Join PortfolioProject..covidvaccinations vac 
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

--use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, rolling_vaccination_total)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as rolling_vaccination_total
From PortfolioProject..coviddeaths dea
Left Join PortfolioProject..covidvaccinations vac 
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT continent, location, MAX(population) as population, MAX(rolling_vaccination_total) as vaccinations, MAX((rolling_vaccination_total/population)*100) as vaccination_percentage
From PopvsVac
GROUP BY continent, location
Order by 2,3;

--Temp table

DROP TABLE if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_vaccination_total numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as rolling_vaccination_total
From PortfolioProject..coviddeaths dea
Left Join PortfolioProject..covidvaccinations vac 
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *, (rolling_vaccination_total/population)*100 as vaccination_percentage
From #PercentPopulationVaccinated;

--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as rolling_vaccination_total
From PortfolioProject..coviddeaths dea
Left Join PortfolioProject..covidvaccinations vac 
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3;