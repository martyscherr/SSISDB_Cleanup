USE [msdb]
GO


BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_SSISDB_prune_data', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Prunes the SSISDB tables for data > X days based on parameter @GETDATE DATETIME passed into stored procedure: dbo.sp_SSISB_prune_data', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Drop_Indexes_During_Purge_Process', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE SSISDB

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = ''FK_ExecutableStatistics_ExecutableId_Executables'')
 ALTER TABLE internal.executable_statistics DROP CONSTRAINT FK_ExecutableStatistics_ExecutableId_Executables;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = ''FK_ExecutableStatistics_ExecutionId_Executions'')
 ALTER TABLE internal.executable_statistics DROP CONSTRAINT FK_ExecutableStatistics_ExecutionId_Executions;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = ''FK_EventMessageContext_EventMessageId_EventMessages'')
 ALTER TABLE internal.event_message_context DROP CONSTRAINT FK_EventMessageContext_EventMessageId_EventMessages;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = ''FK_EventMessagecontext_Operations'')
 ALTER TABLE internal.event_message_context DROP CONSTRAINT FK_EventMessagecontext_Operations;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = ''FK_EventMessages_OperationMessageId_OperationMessage'')
 ALTER TABLE internal.event_messages DROP CONSTRAINT FK_EventMessages_OperationMessageId_OperationMessage;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = ''FK_OperationMessages_OperationId_Operations'')
 ALTER TABLE internal.operation_messages DROP CONSTRAINT FK_OperationMessages_OperationId_Operations;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = ''FK_OperationPermissions_ObjectId_Operations'')
 ALTER TABLE internal.operation_permissions DROP CONSTRAINT FK_OperationPermissions_ObjectId_Operations;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = ''FK_ExecutionParameterValue_ExecutionId_Executions'')
 ALTER TABLE internal.execution_parameter_values DROP CONSTRAINT FK_ExecutionParameterValue_ExecutionId_Executions;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = ''FK_Executables'')
 ALTER TABLE internal.executables DROP CONSTRAINT FK_Executables;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = ''FK_EventMessageContext_EventMessageId_EventMessages'')
 ALTER TABLE internal.event_message_context DROP CONSTRAINT FK_EventMessageContext_EventMessageId_EventMessages;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = ''FK_EventMessagecontext_Operations'')
 ALTER TABLE internal.event_message_context DROP CONSTRAINT FK_EventMessagecontext_Operations;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = ''FK_EventMessagecontext_Operations'')
 ALTER TABLE internal.event_messages DROP CONSTRAINT FK_EventMessages_OperationMessageId_OperationMessage;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = ''FK_OperationMessages_OperationId_Operations'')
 ALTER TABLE internal.operation_messages DROP CONSTRAINT FK_OperationMessages_OperationId_Operations;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = ''FK_OperationPermissions_ObjectId_Operations'')
 ALTER TABLE internal.operation_permissions DROP CONSTRAINT FK_OperationPermissions_ObjectId_Operations;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = ''FK_ExecutableStatistics_ExecutionId_Executions'')
 ALTER TABLE internal.executable_statistics DROP CONSTRAINT FK_ExecutableStatistics_ExecutionId_Executions;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = ''FK_ExecutableStatistics_ExecutableId_Executables'')
 ALTER TABLE internal.executable_statistics DROP CONSTRAINT FK_ExecutableStatistics_ExecutableId_Executables;', 
		@database_name=N'SSISDB', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'execute sp_SSISDB_prune_data', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @getdate datetime = GETDATE()-3;
execute sp_SSISDB_prune_data @getdate;', 
		@database_name=N'SSISDB', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Create_Indexes_After_Purge_Process', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- executable_statistcs
USE [SSISDB]
GO

ALTER TABLE [internal].[executable_statistics]  WITH CHECK ADD  CONSTRAINT [FK_ExecutableStatistics_ExecutableId_Executables] FOREIGN KEY([executable_id])
REFERENCES [internal].[executables] ([executable_id])
ON DELETE CASCADE
GO

ALTER TABLE [internal].[executable_statistics] WITH CHECK CHECK CONSTRAINT [FK_ExecutableStatistics_ExecutableId_Executables]
GO

USE [SSISDB]
GO

ALTER TABLE [internal].[executable_statistics]  WITH CHECK ADD  CONSTRAINT [FK_ExecutableStatistics_ExecutionId_Executions] FOREIGN KEY([execution_id])
REFERENCES [internal].[executions] ([execution_id])
ON DELETE CASCADE
GO

ALTER TABLE [internal].[executable_statistics] CHECK CONSTRAINT [FK_ExecutableStatistics_ExecutionId_Executions]
GO

-- execution_parameter_values
USE [SSISDB]
GO

ALTER TABLE [internal].[execution_parameter_values]  WITH CHECK ADD  CONSTRAINT [FK_ExecutionParameterValue_ExecutionId_Executions] FOREIGN KEY([execution_id])
REFERENCES [internal].[executions] ([execution_id])
ON DELETE CASCADE
GO

ALTER TABLE [internal].[execution_parameter_values] CHECK CONSTRAINT [FK_ExecutionParameterValue_ExecutionId_Executions]
GO


--executables
USE [SSISDB]
GO

ALTER TABLE [internal].[executables]  WITH CHECK ADD  CONSTRAINT [FK_Executables] FOREIGN KEY([project_id])
REFERENCES [internal].[projects] ([project_id])
ON DELETE CASCADE
GO

ALTER TABLE [internal].[executables] CHECK CONSTRAINT [FK_Executables]
GO

-- event_message_context

USE [SSISDB]
GO

ALTER TABLE [internal].[event_message_context]  WITH CHECK ADD  CONSTRAINT [FK_EventMessageContext_EventMessageId_EventMessages] FOREIGN KEY([event_message_id])
REFERENCES [internal].[event_messages] ([event_message_id])
ON DELETE CASCADE
GO

ALTER TABLE [internal].[event_message_context] CHECK CONSTRAINT [FK_EventMessageContext_EventMessageId_EventMessages]
GO

USE [SSISDB]
GO

ALTER TABLE [internal].[event_message_context]  WITH CHECK ADD  CONSTRAINT [FK_EventMessagecontext_Operations] FOREIGN KEY([operation_id])
REFERENCES [internal].[operations] ([operation_id])
GO

ALTER TABLE [internal].[event_message_context] CHECK CONSTRAINT [FK_EventMessagecontext_Operations]
GO

-- event_messages

USE [SSISDB]
GO

ALTER TABLE [internal].[event_messages]  WITH CHECK ADD  CONSTRAINT [FK_EventMessages_OperationMessageId_OperationMessage] FOREIGN KEY([event_message_id])
REFERENCES [internal].[operation_messages] ([operation_message_id])
ON DELETE CASCADE
GO

ALTER TABLE [internal].[event_messages] CHECK CONSTRAINT [FK_EventMessages_OperationMessageId_OperationMessage]
GO

-- operation_messages

USE [SSISDB]
GO

ALTER TABLE [internal].[operation_messages]  WITH CHECK ADD  CONSTRAINT [FK_OperationMessages_OperationId_Operations] FOREIGN KEY(operation_id)
REFERENCES [internal].[operations] ([operation_id])
ON DELETE CASCADE
GO


ALTER TABLE [internal].[operation_messages] CHECK CONSTRAINT [FK_OperationMessages_OperationId_Operations]
GO

-- operation_permissions

USE [SSISDB]
GO

ALTER TABLE [internal].[operation_permissions]  WITH CHECK ADD  CONSTRAINT [FK_OperationPermissions_ObjectId_Operations] FOREIGN KEY([object_id])
REFERENCES [internal].[operations] ([operation_id])
ON DELETE CASCADE
GO

ALTER TABLE [internal].[operation_permissions] CHECK CONSTRAINT [FK_OperationPermissions_ObjectId_Operations]
GO
', 
		@database_name=N'SSISDB', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


