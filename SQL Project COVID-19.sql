
-- Total Death Count (MAX) for a continent.
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from [SQL Project COVID-19]..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Total Death % over different days
Select  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
from [SQL Project COVID-19]..CovidDeaths$
Where continent is not null
Group by date
order by 1,2

-- Rolling People Vaccinated over time
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location
order by dea.location, dea.date) as RollingPeopleVac
from [SQL Project COVID-19]..CovidVaccinations$ vac
Join [SQL Project COVID-19]..CovidDeaths$ dea
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using RollingPeopleVac in CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVac)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location
order by dea.location, dea.date) as RollingPeopleVac
from [SQL Project COVID-19]..CovidVaccinations$ vac
Join [SQL Project COVID-19]..CovidDeaths$ dea
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVac/Population)*100 as PercentRollVac
From PopvsVac

-- Using RollingPeopleVac in Temp Table
Drop Table if exists #PercentPopulationVac
Create Table #PercentPopulationVac
(
Continent nvarchar(255),
Location nvarchar(255),
Data datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVac numeric
)
Insert into #PercentPopulationVac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location
order by dea.location, dea.date) as RollingPeopleVac
from [SQL Project COVID-19]..CovidVaccinations$ vac
Join [SQL Project COVID-19]..CovidDeaths$ dea
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
Select *, (RollingPeopleVac/Population)*100 as PercentPopVac
From #PercentPopulationVac

-- Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.population, vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
from [SQL Project COVID-19]..CovidVaccinations$ vac
Join [SQL Project COVID-19]..CovidDeaths$ dea
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated