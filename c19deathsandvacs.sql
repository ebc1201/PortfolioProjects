/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM `portfolioproject-352502.covid_deaths.covid_deaths`
WHERE continent IS NOT null
ORDER BY 3, 4;


-- Select Data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM `portfolioproject-352502.covid_deaths.covid_deaths`
WHERE continent IS NOT null
ORDER BY 1, 2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM `portfolioproject-352502.covid_deaths.covid_deaths`
WHERE location like '%States'
AND continent IS NOT null
ORDER BY 1, 2;

-- Total Cases vs Population
-- Shows what percentage of population got Covid.
SELECT Location, date, population, total_cases, (total_cases/population)*100 as percent_population_infected
FROM `portfolioproject-352502.covid_deaths.covid_deaths`
WHERE location like '%States'
ORDER BY 1, 2;

-- Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM `portfolioproject-352502.covid_deaths.covid_deaths`
-- WHERE location like '%States'
GROUP BY location, population
ORDER BY percent_population_infected DESC;


-- Breaking things down by continent
-- Continents with the Highest Death Count per Population
SELECT continent, MAX(cast(total_deaths AS int)) AS total_death_count
FROM `portfolioproject-352502.covid_deaths.covid_deaths`
WHERE continent IS NOT null
GROUP BY continent
ORDER BY total_death_count DESC;


-- GLOBAL NUMBERS
-- Total number of cases, death, and death percentage per day
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM `portfolioproject-352502.covid_deaths.covid_deaths`
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1, 2;

-- Total number of cases, death, and death percentage
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM `portfolioproject-352502.covid_deaths.covid_deaths`
WHERE continent IS NOT null
ORDER BY 1, 2;

--Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
  --,(rolling_people_vaccinated/population)*100
FROM `portfolioproject-352502.covid_deaths.covid_deaths` AS dea
JOIN `portfolioproject-352502.covid_deaths.covid_vaccinations` AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2, 3

--USE CTE
WITH popvsvac AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM `portfolioproject-352502.covid_deaths.covid_deaths` AS dea
JOIN `portfolioproject-352502.covid_deaths.covid_vaccinations` AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (rolling_people_vaccinated/Population) * 100 AS percent_pop_vaccinated
FROM popvsvac;