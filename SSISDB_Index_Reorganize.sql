USE SSISDB

SELECT 'ALTER INDEX ' + I.name + ' ON internal.' +  OBJECT_NAME(ips.object_id) + ' REORGANIZE;',
OBJECT_NAME(ips.object_id) AS TableName
	,i.name AS IndexName
	,ips.index_type_desc AS IndexType
	,ips.avg_fragmentation_in_percent 
	,ips.fragment_count
	,ips.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(),NULL, NULL, NULL ,NULL) AS ips
INNER JOIN sys.indexes AS i ON ips.OBJECT_ID = i.OBJECT_ID
	AND ips.index_id = i.index_id
WHERE 1=1
--ips.page_count > 1000
--AND ips.avg_fragmentation_in_percent > 30
AND OBJECT_NAME(ips.object_id) IN
(
'executable_statistcs'
,'execution_parameter_values'
,'executables'
,'executions'
,'event_message_context'
,'event_messages'
,'operation_messages'
,'operation_permissions'
)
ORDER BY ips.avg_fragmentation_in_percent DESC, ips.page_count DESC 
;



/*

ALTER INDEX PK_Execution_Parameter_value ON internal.execution_parameter_values REORGANIZE;

ALTER INDEX IXNNJF20190201_execution_parameter_values__executionid_parametername ON internal.execution_parameter_values REORGANIZE;

ALTER INDEX Unique_OperationPermissions ON internal.operation_permissions REORGANIZE;

ALTER INDEX PK_Operation_Permissions ON internal.operation_permissions REORGANIZE;

ALTER INDEX IX_OperationMessages_Operation_id ON internal.operation_messages REORGANIZE;

ALTER INDEX IX_EventMessageContext_Operation_id ON internal.event_message_context REORGANIZE;

ALTER INDEX ix_execution_parameter_values ON internal.execution_parameter_values REORGANIZE;

ALTER INDEX IX_ExecutionParameterValue_ExecutionId ON internal.execution_parameter_values REORGANIZE;

ALTER INDEX PK_Executables ON internal.executables REORGANIZE;

ALTER INDEX IX_OperationMessages_Operation_id ON internal.operation_messages REORGANIZE;

ALTER INDEX PK_Executions ON internal.executions REORGANIZE;

ALTER INDEX IXNNJF20190201_event_message_context__eventmessageid ON internal.event_message_context REORGANIZE;

ALTER INDEX PK_Event_Messages ON internal.event_messages REORGANIZE;

ALTER INDEX IX_EventMessageContext_Operation_id ON internal.event_message_context REORGANIZE;

--ALTER INDEX PK_Event_Message_Context ON internal.event_message_context REORGANIZE;

ALTER INDEX PK_Operation_Messages ON internal.operation_messages REORGANIZE;

*/


