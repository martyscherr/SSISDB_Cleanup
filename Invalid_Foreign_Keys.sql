USE SSISDB

SELECT f.*, '[' + s.name + '].[' + o.name + '].[' + f.name + ']' AS ForeignKeyName
FROM    sys.foreign_keys f
INNER JOIN sys.objects o 
	ON f.parent_object_id = o.object_id
INNER JOIN sys.schemas s 
	ON o.schema_id = s.schema_id
WHERE   1=1
	AND f.is_not_trusted = 1
	AND F.is_not_for_replication = 0
	AND f.is_disabled = 1
	AND o.name IN
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