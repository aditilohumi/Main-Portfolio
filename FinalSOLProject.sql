Select *
	From [Portfolio Project]..CovidDeaths
	Where continent is not null
	order by 3,4
	
--Select *
	--From [Portfolio Project]..CovidVaccinations
	--order by 3,4

--Selection of Data that we will use
Select location, date, total_cases, new_cases, total_deaths, population
	From [Portfolio Project]..CovidDeaths
	Where continent is not null
	order by 1,2

--Analysis of Total Cases vs Deaths
--Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
	From [Portfolio Project]..CovidDeaths
	Where location like 'India' and continent is not null
	order by 1,2

--Analysis of Total Cases vs Population
--Evaluation of the percentage that contracts COVID19
Select location, date, total_cases, population, (total_cases/population)*100 as Contraction_Rate
	From [Portfolio Project]..CovidDeaths
--	Where location like 'India' 
	Where continent is not null
	order by 1,2

--Country with Infection Count per Population for countries
Select location, MAX(total_cases) as Infection_Count, population, MAX(total_cases/population)*100 as Contraction_Rate
	From [Portfolio Project]..CovidDeaths
--	Where location like 'India'
	Where continent is not null
	Group by location, population
	order by Contraction_Rate desc

--Depiction of countries with the Death Count per Population for countries
Select location, MAX(cast(total_deaths as int)) as Death_Count
	From [Portfolio Project]..CovidDeaths
--	Where location like 'India'
	Where continent is not null
	Group by location
	order by Death_Count desc

	--DATA AS A REPRESENTATION BASED ON CONTINENTS
	Select location, MAX(cast(total_deaths as int)) as Death_Count
	From [Portfolio Project]..CovidDeaths
--	Where location like 'India'
	Where continent is null
	Group by location
	order by Death_Count desc


--GLOBAL NUMBERS
	Select date, SUM(new_cases) as Cases, SUM(cast(new_deaths as int)) as Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
	From [Portfolio Project]..CovidDeaths
--	Where location like 'India'
	Where continent is not null
	Group by date
	order by 1,2 desc

-- Total Population vs Vaccinations
Select dea.continent,dea.date, dea.location, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location ,dea.date) as Cumulative_Vaccination
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	order by 2, 3

--CTE USAGE

With PopsVac (continent, date, location, population, new_vaccinations, Cumulative_Vaccination)
as
(
Select dea.continent,dea.date, dea.location, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location ,dea.date) as Cumulative_Vaccination
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	--order by 2, 3
)
Select * , Cumulative_Vaccination/population*100
From PopsVac

-- Country with Max Vaccination percentage wiith TEMP Table

Drop table if exists #PercPopVac
Create Table #PercPopVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vac numeric,
CumulativeVac numeric
)
Insert into #PercPopVac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location ,dea.date) as Cumulative_Vaccination
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	--Where dea.continent is not null
	--order by 2, 3
Select * , CumulativeVac/Population*100
From #PercPopVac



--View creation to store data for later visualtion
Create View PercPopVaca as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location ,dea.date) as Cumulative_Vaccination
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	--order by 2, 3

Select*
From PercPopVaca