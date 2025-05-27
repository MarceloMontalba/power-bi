-- Tabla de usuario
SELECT DISTINCT CASE WHEN a.id IS NULL THEN c.user_id ELSE a.id END usua_codigo, 
	   a.name usua_nombres, LOWER(RTRIM(LTRIM(b.address))) usua_email, 
	   c.username usua_nombre_usuario, a.created usua_fecha_creacion
FROM inkatun.ost_user a
INNER JOIN inkatun.ost_user_email b ON a.id=b.user_id
INNER JOIN inkatun.ost_user_account c ON a.id=c.user_id
LEFT JOIN inkatun.ost_ticket d ON d.user_id=a.id
WHERE a.id IS NULL
ORDER BY a.id ASC;

SELECT COUNT(*)
FROM inkatun.ost_user a
INNER JOIN inkatun.ost_user_email b ON a.id=b.user_id
INNER JOIN inkatun.ost_user_account c ON a.id=c.user_id

-- Tabla de Ticket
SELECT a.ticket_id tick_codigo, a.number tick_numero, a.user_id usua_codigo, a.status_id esti_codigo, 
	   a.sla_id slati_codigo, a.topic_id teayti_codigo, a.staff_id agen_codigo,
       CASE WHEN a.isoverdue=0 THEN "PUNTUAL" ELSE "VENCIDO" END maveti_nombre, 
       CASE WHEN a.isanswered=0 THEN "SIN RESPUESTA" ELSE "RESPONDIDO" END mareti_nombre, 
       a.created tick_fecha_creacion, a.duedate tick_fecha_limite, a.est_duedate tick_fecha_estimada, 
       a.closed tick_fecha_cierre, a.updated tick_fecha_actualizacion, 
       CASE WHEN TIMESTAMPDIFF(SECOND, a.created, c.created)>0 THEN TIMESTAMPDIFF(SECOND, a.created, c.created) ELSE 0 END tick_tiempo_abierto,
       CASE WHEN TIMESTAMPDIFF(SECOND, c.created, a.closed)>0 THEN TIMESTAMPDIFF(SECOND, c.created, a.closed) ELSE 0 END tick_tiempo_proceso,
       CASE WHEN TIMESTAMPDIFF(SECOND, a.created, a.closed)>0 THEN TIMESTAMPDIFF(SECOND, a.created, a.closed) ELSE 0 END tick_tiempo_cerrado
FROM inkatun.ost_ticket a
LEFT JOIN inkatun.ost_thread b ON a.ticket_id=b.object_id
LEFT JOIN (SELECT thread_id, MIN(created) created 
            FROM inkatun.ost_thread_entry WHERE user_id=0 AND staff_id<>0 GROUP BY thread_id) c
ON b.id=c.thread_id
WHERE b.object_type="T" AND a.topic_id IN (13,23,29);

-- Tabla estado ticket
SELECT a.id inties_codigo, a.name inties_nombre
FROM inkatun.ost_ticket_status a;

-- Tabla sla ticket
SELECT a.id intisla_codigo, a.grace_period intisla_periodo_gracia, a.name intisla_nombre
FROM inkatun.ost_sla a;

-- Tabla temas de ayuda
SELECT a.topic_id teayti_codigo, CASE WHEN a.ispublic=0 THEN "PRIVADO" ELSE "PÚBLICO" END teayti_acceso, UPPER(a.topic) teayti_nombre
FROM inkatun.ost_help_topic a;

-- Tabla agente
SELECT a.staff_id inag_codigo, a.username inag_nombre_usuario, CONCAT(a.firstname,' ',a.lastname) inag_nombre, 
	   a.email inag_email, a.created inag_fecha_creacion, a.lastlogin inag_fecha_login, 
       a.updated inag_fecha_actualizacion
FROM inkatun.ost_staff a;

-- Selecciones realizadas por temas de ayuda
-- PDT: Hablar en PowerBI de por que no se fragmentaron en 3 tablas debido al choque que podria haber entre temas de ayuda
SELECT a.ticket_id foti_codigo,
       g.label foti_campo,
       REPLACE(
         REPLACE(
           REPLACE(
             REPLACE(
               REPLACE(
                 REPLACE(
                   REPLACE(
                     REPLACE(
                       REPLACE(
                         REPLACE(
                           REPLACE(
	                         REPLACE(
							   REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(f.value, '":"', -1), '"', 1), 
                               '\\u00c1','Á'),
							 '\\u00c9', 'É'),
						   '\\u00cd', 'Í'),
	                     '\\u00d3', 'Ó'),
	                   '\\u00da', 'Ú'),
                     '\\u00d1', 'Ñ'),
				   '\\u00e1','á'),
                 '\\u00e9', 'é'),
               '\\u00ed', 'í'),
             '\\u00f3', 'ó'),
           '\\u00fa', 'ú'),
         '\\u00f1', 'ñ'),
       '\\','') foti_respuesta
FROM inkatun.ost_ticket a
INNER JOIN inkatun.ost_help_topic b ON a.topic_id=b.topic_id
INNER JOIN inkatun.ost_help_topic_form c ON b.topic_id=c.topic_id
INNER JOIN inkatun.ost_form d ON c.form_id=d.id 
INNER JOIN inkatun.ost_form_entry e ON d.id=e.form_id AND a.ticket_id=e.object_id
INNER JOIN (
    SELECT entry_id, field_id, value FROM inkatun.ost_form_entry_values
    WHERE value REGEXP '^\\{"[0-9]+":"[^"]+(?<!\\.pdf|\\.docx|\\.doc|\\.txt|\\.rtf|\\.odt|\\.xlsx|\\.xls|\\.csv|\\.pptx|\\.ppt|\\.odp|\\.html|\\.xml|\\.json)"\\}$'
) f ON e.id=f.entry_id
INNER JOIN inkatun.ost_form_field g ON f.field_id=g.id AND d.id=g.form_id
WHERE a.topic_id IN (13,23,29)
ORDER BY a.ticket_id DESC;

-- eventos
SELECT DISTINCT * FROM
(
	(SELECT a.ticket_id,
		CASE
			WHEN c.event_id=1 THEN "CREADO"
			WHEN c.event_id=2 THEN "CERRADO"
			WHEN c.event_id=3 THEN "REABIERTO"
			WHEN c.event_id=4 THEN "ASIGNADO"
			WHEN c.event_id=5 THEN "LIBERADO"
			WHEN c.event_id=6 THEN "TRANSFERIDO"
			WHEN c.event_id=7 THEN "REFERIDO"
			WHEN c.event_id=8 THEN "VENCIDO"
			WHEN c.event_id=9 THEN "EDITADO"
			WHEN c.event_id=10 THEN "VISITADO"
			WHEN c.event_id=11 THEN "ERROR"
			WHEN c.event_id=12 THEN "COLABORADO"
			WHEN c.event_id=13 THEN "REENVIADO"
			WHEN c.event_id=14 THEN "ELIMINADO"
			WHEN c.event_id=15 THEN "FUSIONADO"
			WHEN c.event_id=16 THEN "DESVINCULADO"
			WHEN c.event_id=17 THEN "VINCULADO"
			WHEN c.event_id=20 THEN "ENVIÓ UN MENSAJE"
			WHEN c.event_id=21 THEN "CREÓ UNA NOTA/COMENTARIO"
		END tipo_evento, c.timestamp fecha_evento
	FROM inkatun.ost_ticket a
	INNER JOIN inkatun.ost_thread b ON a.ticket_id=b.object_id AND b.object_type="T"
	INNER JOIN inkatun.ost_thread_event c ON b.id=c.thread_id AND thread_type="T" AND c.staff_id<>0
	WHERE c.event_id IN (2,3,4,5,6,7,9,12,13,14,15,16,17))
	UNION ALL
	(SELECT a.ticket_id, "CERRADO" tipo_evento, a.closed fecha_evento 
	FROM inkatun.ost_ticket a
	WHERE a.closed<>"" OR a.closed IS NOT NULL)
) a
ORDER BY a.ticket_id DESC;

-- Participaciones tickets
SELECT DISTINCT * FROM (
	(SELECT DISTINCT a.ticket_id tick_codigo, c.staff_id agen_codigo,
           CASE 
			WHEN c.type="R" THEN "TICKETS RESPONDIDOS"  
			WHEN c.type="M" THEN "TICKETS MENSAJEADOS" 
			WHEN c.type="N" THEN "TICKETS COMENTADOS" 
		   END acag_tipo_accion, c.created acag_fecha_accion
	FROM inkatun.ost_ticket a
	INNER JOIN inkatun.ost_thread b ON a.ticket_id=b.object_id AND b.object_type="T"
	INNER JOIN inkatun.ost_thread_entry c ON b.id=c.thread_id AND c.staff_id<>0 AND c.user_id=0
        WHERE a.topic_id IN (13,23,29))
	UNION ALL
	(SELECT DISTINCT a.ticket_id tick_codigo, c.staff_id agen_codigo, 
        CASE
			WHEN c.event_id=1 THEN "TICKETS CREADOS"
			WHEN c.event_id=2 THEN "TICKETS CERRADOS"
			WHEN c.event_id=3 THEN "TICKETS REABIERTOS"
			WHEN c.event_id=4 THEN "TICKETS ASIGNADOS"
			WHEN c.event_id=5 THEN "TICKETS LIBERADOS"
			WHEN c.event_id=6 THEN "TICKETS TRANSFERIDOS"
			WHEN c.event_id=7 THEN "TICKETS REFERIDOS"
			WHEN c.event_id=9 THEN "TICKETS EDITADOS"
			WHEN c.event_id=12 THEN "TICKETS COLABORADOS"
			WHEN c.event_id=13 THEN "TICKETS REENVIADOS"
			WHEN c.event_id=14 THEN "TICKETS ELIMINADOS"
			WHEN c.event_id=15 THEN "TICKETS FUSIONADOS"
			WHEN c.event_id=16 THEN "TICKETS DESVINCULADOS"
			WHEN c.event_id=17 THEN "TICKETS VINCULADOS"
			WHEN c.event_id=20 THEN "TICKETS MENSAJEADOS"
			WHEN c.event_id=21 THEN "TICKETS COMENTADOS"
		END acag_tipo_accion, c.timestamp acag_fecha_accion
	FROM inkatun.ost_ticket a
	INNER JOIN inkatun.ost_thread b ON a.ticket_id=b.object_id AND b.object_type="T"
	INNER JOIN inkatun.ost_thread_event c ON b.id=c.thread_id AND thread_type="T" AND c.staff_id<>0
	WHERE c.event_id IN (2,3,4,5,6,7,9,12,13,14,15,16,17,20,21) AND a.topic_id IN (13,23,29))
	UNION ALL
	(SELECT a.ticket_id tick_codigo, a.staff_id agen_codigo, "TICKETS CERRADOS" acag_tipo_accion, a.closed acag_fecha_accion
	FROM inkatun.ost_ticket a
	WHERE a.closed<>"" OR a.closed IS NOT NULL AND a.topic_id IN (13,23,29))
) a
ORDER BY a.tick_codigo DESC;

-- --------------------------------------------------
-- Tiempo de respuesta general de los agentes participantes en los distintos tickets
SELECT prat.ticket_id, prat.staff_id, ROUND(AVG(tiempo_respuesta)) tiempo_respuesta_segundos
FROM (
	-- Se obtiene la diferencia en segundos entre el mensaje del agente y el mensaje anterior
	SELECT a.ticket_id, a.staff_id, TIMESTAMPDIFF(SECOND, b.created, a.created) tiempo_respuesta
	FROM ( 
		-- Se obtienen TODOS los mensajes de agentes
		SELECT a.ticket_id,c.staff_id, c.body, c.created 
		FROM inkatun.ost_ticket a
		INNER JOIN inkatun.ost_thread b ON a.ticket_id=b.object_id
		INNER JOIN inkatun.ost_thread_entry c ON b.id=c.thread_id
		WHERE c.staff_id<>0 AND c.user_id=0 AND a.topic_id IN (13,23,29)
	) a 
	LEFT JOIN (
		-- Se obtienen los mensajes previos a los de cada agente
		SELECT a.ticket_id, c.staff_id, c.body, c.created 
		FROM inkatun.ost_ticket a
		INNER JOIN inkatun.ost_thread b ON a.ticket_id=b.object_id
		INNER JOIN inkatun.ost_thread_entry c ON b.id=c.thread_id
        WHERE a.topic_id IN (13,23,29)
	) b ON a.ticket_id=b.ticket_id AND a.created>b.created AND 
		NOT EXISTS ( 
			-- Subconsulta que se asegura solo de tomar el mensaje anterior al del agente
			SELECT 1 FROM inkatun.ost_ticket a2
			INNER JOIN inkatun.ost_thread b2 ON a2.ticket_id=b2.object_id
			INNER JOIN inkatun.ost_thread_entry c2 ON b2.id=c2.thread_id
			WHERE a2.ticket_id = a.ticket_id 
				  AND c2.created > b.created 
				  AND c2.created < a.created
                  AND a2.topic_id IN (13,23,29)
		)
	-- Condicion que se asegura de descartar los mensajes del mismo agente (esto en caso de que el agente haya enviado un mensaje seguido)
	WHERE a.staff_id<>b.staff_id
) prat -- Promedio-respuesta-agente-ticket
WHERE prat.ticket_id in(22990,22741,22295)
GROUP BY prat.ticket_id, prat.staff_id
ORDER BY prat.ticket_id DESC;

-- Tiempo de servicio de cada agente en cada ticket
SELECT * FROM (
	-- Se obtienen el tiempo de servicio de los agentes por cada ticket
	SELECT e.ticket_id, e.staff_id, 
	TIMESTAMPDIFF(SECOND, e.created, MAX(e.fecha)) tiempo_servicio_segundos -- Si es null es porque el agente pudo haber tenido un solo mensaje
	FROM (
		(
			-- Eventos que han realizado los agentes
			SELECT a.ticket_id, a.created, c.staff_id, c.timestamp fecha FROM inkatun.ost_ticket a
			INNER JOIN inkatun.ost_thread b ON a.ticket_id=b.object_id AND b.object_type="T"
			LEFT JOIN inkatun.ost_thread_event c ON b.id=c.thread_id AND c.thread_type="T" AND c.staff_id<>0
			WHERE a.topic_id IN (13,23,29) AND c.event_id IN (2,3,4,5,6,7,9,12,13,14,15,16,17,20,21) AND (c.staff_id IS NOT NULL AND c.timestamp IS NOT NULL) -- Eventos admitidos
		)
		UNION ALL (
			-- Mensajes que han escrito de los agentes
			SELECT a.ticket_id, a.created, c.staff_id, c.created fecha FROM inkatun.ost_ticket a
			INNER JOIN inkatun.ost_thread b ON a.ticket_id=b.object_id AND b.object_type="T"
			LEFT JOIN inkatun.ost_thread_entry c ON b.id=c.thread_id AND c.staff_id<>0 AND c.user_id=0
			WHERE c.staff_id IS NOT NULL AND c.created IS NOT NULL AND a.topic_id IN (13,23,29)
		)
		UNION ALL (
			-- Tickets que han cerrado los agentes
			SELECT a.ticket_id, a.created, a.staff_id, a.closed fecha
			FROM inkatun.ost_ticket a
			WHERE a.closed<>"" OR a.closed IS NOT NULL AND a.topic_id IN (13,23,29)
		)
	) e
	GROUP BY ticket_id, staff_id
) z
WHERE z.tiempo_servicio_segundos IS NOT NULL and z.ticket_id in(22990,22741,22295)
ORDER BY z.ticket_id DESC