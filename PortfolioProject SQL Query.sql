Select *
FROM PortfolioProject..CovidDeaths
where continent is not null
Order By 3,4

--Select *
--FROM PortfolioProject..CovidVaccinations
--Order By 3,4

--Select Data for Project

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order By 1,2


-- Looking at Total Cases vs Total Deaths
-- Likelihood of Death from Contracting Covid By Country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
Order By 1,2


-- Looking at Total Cases vs Population
-- Shows percentage of Population that contracted Covid
Select location, date, total_cases, Population, (total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
Order By 1,2

-- Looking at Countries with highest Infection rate compared to Population
Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
Group by population, location
Order By PercentPopInfected desc



--Showing Countries with Highest Death Count Per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
Order By TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT


--Showing Countries with Highest Death Count Per Population by Continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
Order By TotalDeathCount desc


-- Showing Continents with Highest Death Count per Population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
Order By TotalDeathCount desc


-- GLOBAL NUMBERS 

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by date
Order By 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPopVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USING A CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPopVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPopVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPopVaccinated/population)*100 RollingVaxPercentage
From PopvsVac

-- USING A TEMP TABLE

Drop Table if exists #PercentPopVaccinated
Create Table #PercentPopVaccinated
(
continent nvarchar(255), 
location nvarchar(255),
date datetime, 
population float,
new_vaccinations numeric,
RollingPopVaccianted numeric,
)

Insert into #PercentPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPopVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Creating View to Store Data For Later Visiualizations 

Create View PercentPopVaccinated1 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPopVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopVaccinated