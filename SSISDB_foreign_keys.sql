
USE [SSISDB]
GO

SELECT
'ALTER TABLE ' + s.name + '.' + t.name + ' DROP CONSTRAINT ' + f.name + ';'
--t.name AS TableName, f.*
FROM    sys.foreign_keys f
JOIN sys.tables t ON t.[object_id] = f.parent_object_id
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE t.name IN 
(
'executable_statistics'
,'execution_parameter_values'
,'executables'
,'executions'
,'event_message_context'
,'event_messages'
,'operation_messages'
,'operation_permissions'
);

/*

ALTER TABLE internal.executable_statistics DROP CONSTRAINT FK_ExecutableStatistics_ExecutableId_Executables;
ALTER TABLE internal.executable_statistics DROP CONSTRAINT FK_ExecutableStatistics_ExecutionId_Executions;
ALTER TABLE internal.event_message_context DROP CONSTRAINT FK_EventMessageContext_EventMessageId_EventMessages;
ALTER TABLE internal.event_message_context DROP CONSTRAINT FK_EventMessagecontext_Operations;
ALTER TABLE internal.event_messages DROP CONSTRAINT FK_EventMessages_OperationMessageId_OperationMessage;
ALTER TABLE internal.operation_messages DROP CONSTRAINT FK_OperationMessages_OperationId_Operations;
ALTER TABLE internal.operation_permissions DROP CONSTRAINT FK_OperationPermissions_ObjectId_Operations;

ALTER TABLE internal.execution_parameter_values DROP CONSTRAINT FK_ExecutionParameterValue_ExecutionId_Executions;
ALTER TABLE internal.executables DROP CONSTRAINT FK_Executables;
ALTER TABLE internal.event_message_context DROP CONSTRAINT FK_EventMessageContext_EventMessageId_EventMessages;
ALTER TABLE internal.event_message_context DROP CONSTRAINT FK_EventMessagecontext_Operations;
ALTER TABLE internal.event_messages DROP CONSTRAINT FK_EventMessages_OperationMessageId_OperationMessage;
ALTER TABLE internal.operation_messages DROP CONSTRAINT FK_OperationMessages_OperationId_Operations;
ALTER TABLE internal.operation_permissions DROP CONSTRAINT FK_OperationPermissions_ObjectId_Operations;
ALTER TABLE internal.executable_statistics DROP CONSTRAINT FK_ExecutableStatistics_ExecutionId_Executions;
ALTER TABLE internal.executable_statistics DROP CONSTRAINT FK_ExecutableStatistics_ExecutableId_Executables;

*/

/*

-- executable_statistcs
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

ALTER TABLE [internal].[operation_messages]  WITH CHECK ADD  CONSTRAINT [FK_OperationMessages_OperationId_Operations] FOREIGN KEY([operation_id])
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

*/