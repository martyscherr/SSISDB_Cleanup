USE SSISDB

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = 'FK_ExecutableStatistics_ExecutableId_Executables')
 ALTER TABLE internal.executable_statistics DROP CONSTRAINT FK_ExecutableStatistics_ExecutableId_Executables;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = 'FK_ExecutableStatistics_ExecutionId_Executions')
 ALTER TABLE internal.executable_statistics DROP CONSTRAINT FK_ExecutableStatistics_ExecutionId_Executions;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = 'FK_EventMessageContext_EventMessageId_EventMessages')
 ALTER TABLE internal.event_message_context DROP CONSTRAINT FK_EventMessageContext_EventMessageId_EventMessages;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = 'FK_EventMessagecontext_Operations')
 ALTER TABLE internal.event_message_context DROP CONSTRAINT FK_EventMessagecontext_Operations;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = 'FK_EventMessages_OperationMessageId_OperationMessage')
 ALTER TABLE internal.event_messages DROP CONSTRAINT FK_EventMessages_OperationMessageId_OperationMessage;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = 'FK_OperationMessages_OperationId_Operations')
 ALTER TABLE internal.operation_messages DROP CONSTRAINT FK_OperationMessages_OperationId_Operations;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = 'FK_OperationPermissions_ObjectId_Operations')
 ALTER TABLE internal.operation_permissions DROP CONSTRAINT FK_OperationPermissions_ObjectId_Operations;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = 'FK_ExecutionParameterValue_ExecutionId_Executions')
 ALTER TABLE internal.execution_parameter_values DROP CONSTRAINT FK_ExecutionParameterValue_ExecutionId_Executions;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = 'FK_Executables')
 ALTER TABLE internal.executables DROP CONSTRAINT FK_Executables;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = 'FK_EventMessageContext_EventMessageId_EventMessages')
 ALTER TABLE internal.event_message_context DROP CONSTRAINT FK_EventMessageContext_EventMessageId_EventMessages;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = 'FK_EventMessagecontext_Operations')
 ALTER TABLE internal.event_message_context DROP CONSTRAINT FK_EventMessagecontext_Operations;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = 'FK_EventMessagecontext_Operations')
 ALTER TABLE internal.event_messages DROP CONSTRAINT FK_EventMessages_OperationMessageId_OperationMessage;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = 'FK_OperationMessages_OperationId_Operations')
 ALTER TABLE internal.operation_messages DROP CONSTRAINT FK_OperationMessages_OperationId_Operations;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = 'FK_OperationPermissions_ObjectId_Operations')
 ALTER TABLE internal.operation_permissions DROP CONSTRAINT FK_OperationPermissions_ObjectId_Operations;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = 'FK_ExecutableStatistics_ExecutionId_Executions')
 ALTER TABLE internal.executable_statistics DROP CONSTRAINT FK_ExecutableStatistics_ExecutionId_Executions;

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE name = 'FK_ExecutableStatistics_ExecutableId_Executables')
 ALTER TABLE internal.executable_statistics DROP CONSTRAINT FK_ExecutableStatistics_ExecutableId_Executables;