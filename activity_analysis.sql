---
---Current activity analysis 
---
SELECT	spid, event_type, parameters, event_info
FROM	tbCurrent_Activity_inputbuffer_data
WHERE	(sample_date > '03/18/2004 10:40')
order by spid
---
--- 
---
SELECT	distinct spid, event_type, parameters, event_info
FROM	tbCurrent_Activity_inputbuffer_data
WHERE	(sample_date > '03/18/2004 10:40')
order by spid
---
---
---
SELECT	count(spid + event_type + parameters + event_info) as count,
	(spid + event_type + parameters + event_info) as inputbuffer 
FROM	tbCurrent_Activity_inputbuffer_data
WHERE	(sample_date > '03/18/2004 10:40')
and 	(sample_date < '03/18/2004 10:50')
group by spid + event_type + parameters + event_info
order by spid + event_type + parameters + event_info
---
---
---
SELECT	count(event_info) as count,
	(event_info) as inputbuffer 
FROM	tbCurrent_Activity_inputbuffer_data
WHERE	(sample_date > '03/18/2004 10:40')
and 	(sample_date < '03/18/2004 10:50')
group by event_info
order by event_info