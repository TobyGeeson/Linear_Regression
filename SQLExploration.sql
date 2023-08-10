-- To begin, we'll choose some data and sort it according to the first and second columns (location and date).

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

 
-- I'm going to compare the number of cases to the number of fatalities. how many cases there are countrywide and how many people die from each case.
--demonstrates the risk of death from covid in a country.
--Note that the CAST function is used to convert the 'total_cases' and 'total_deaths' columns to decimal data type before dividing them, and the

--multiplication by 100 is performed after the division to get the percentage value.
SELECT Location, date, total_cases, total_deaths, 
       (CAST(total_deaths AS decimal)/CAST(total_cases AS decimal))*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL 
ORDER BY 1,2


-- Total Cases vs. Population, Indicates the proportion of the population that is Covid-infected.

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
order by 1,2

​

​

--Highest Infection Rate Countries (also known as Max total_cases, with the alias HighestInfectionCount) in Relation to Population
--to view the highest to lowest of%  by population of reported COVID cases, arranged on PercentPopulationInfected in descending order.
--could also use, for instance, Where location like "%France%" etc., to show on the country level

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

​

​
-- looking at the highest death count, so we need Max total deaths, ordered desc
--there was an issue with data type. (nvarchar(255),null)so had to cast as an integer.
-- added where the continent is not null, as where it is null, the location is seen as the entire continent, this could be included for every query.

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

 


-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

 


-- for the purposes of future visualisation.
--no location, continent included - global level

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

​

​

--Total Population vs Vaccinations, shows Percentage of Population that has recieved at least one Covid Vaccine
--join the tables
-- This SQL code retrieves COVID-19 deaths and vaccination data from two tables, calculates the cumulative sum of new vaccinations for each location, and filters the data to only include rows with non-null continent values, before sorting the results by location and date.
--CONVERT function is used to convert the 'new_vaccinations' column to a bigint data type before performing the SUM operation. The resulting value is ---then cast to a decimal data type to avoid the arithmetic overflow error.
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       CAST(SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS decimal) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

  

-- Creating View to store data for later visualisations
-- Once the view is created, it can be used as a table in subsequent queries to retrieve the same data.

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null 
