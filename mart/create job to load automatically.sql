--create job load data
EXEC msdb.dbo.sp_add_job
	@job_name = N'Job_load_data_into_datawarehouse',
	@enabled = 1,
	@description = N'Job load data from web database to data warehouse';

--add steps to job
EXEC msdb.dbo.sp_add_jobstep
	@job_name = N'Job_load_data_into_datawarehouse',
	@step_name = N'Step 1 - load from web database into bronze layer',
	@subsystem = N'TSQL',
	@command = N'EXEC DataWarehouse.bronze.load_bronze',
	@database_name = N'DataWarehouse',
	@on_success_action = 1;

EXEC msdb.dbo.sp_add_jobstep
	@job_name = N'Job_load_data_into_datawarehouse',
	@step_name = N'Step 2 - load from bronze layer into silver layer',
	@subsystem = N'TSQL',
	@command = N'EXEC DataWarehouse.silver.load_silver',
	@database_name = N'DataWarehouse',
	@on_success_action = 1;

EXEC msdb.dbo.sp_add_jobstep
	@job_name = N'Job_load_data_into_datawarehouse',
	@step_name = N'Step 3 - load from silver layer into gold layer',
	@subsystem = N'TSQL',
	@command = N'EXEC DataWarehouse.gold.load_gold',
	@database_name = N'DataWarehouse',
	@on_success_action = 1;

EXEC msdb.dbo.sp_add_jobstep
	@job_name = N'Job_load_data_into_datawarehouse',
	@step_name = N'Step 4 - load from gold layer into mart',
	@subsystem = N'TSQL',
	@command = N'EXEC DataWarehouse.mart.load_mart',
	@database_name = N'DataWarehouse',
	@on_success_action = 1;

--create schedule
EXEC msdb.dbo.sp_add_schedule
	@schedule_name = N'load everyday at 1:00 am',
	@freq_type = 4,
	@freq_interval = 1,
	@active_start_time = 010000;

--attach schedule to job
EXEC msdb.dbo.sp_attach_schedule
	@job_name = N'Job_load_data_into_datawarehouse',
	@schedule_name = N'load everyday at 1:00 am';

--add job to sql server agent
EXEC msdb.dbo.sp_add_jobserver
	@job_name = N'Job_load_data_into_datawarehouse';