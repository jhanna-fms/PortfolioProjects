/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [continent]
      ,[location]
      ,[date]
      ,[population]
      ,[new_vaccinations]
      ,[RollingPeopleVaccinated]
  FROM [Portfolio Project].[dbo].[PercentPopulationVaccinated]


  --You can use regular queries
  select *
  from PercentPopulationVaccinated