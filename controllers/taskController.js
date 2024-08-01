require('dotenv').config();
const pool = require('../utils/database');

exports.insertTask = (req, res) => {
  const { 
 project, task_name, dept, create_date, end_date, descr , created_by, status, empcode
  } = req.body;
  
  const insertSql = `
  INSERT INTO tbl_timesheet_task_master (
     project, task_name, dept, create_date, end_date, descr, created_by, status, empcode
  ) 
  VALUES (
     @project, @task_name, @dept, CONVERT(date, @create_date, 23), @end_date, @descr, @created_by, @status, @empcode
  )
  `;

  pool.request()
    .input('project', project)
    .input('task_name', task_name)
    .input('create_date', create_date)
    .input('dept', dept)
    .input('end_date', end_date)
    .input('descr', descr)
    .input('created_by', created_by)
    .input('status', status)
    .input('empcode', empcode)
    .query(insertSql, (insertErr, insertResult) => {
      if (insertErr) {
        console.error('Error inserting task record: ', insertErr);
        return res.status(500).json({ message: 'Error inserting task record' });
      }
      res.status(200).json({ message: 'Task record inserted successfully' });
    });
};

exports.fetchTask = (req, res) => {
  const { empcode } = req.body; 

  const fetchSql = `
    SELECT ID, empcode, project, task_name, create_date, dept, end_date, descr, created_by, status
    FROM tbl_timesheet_task_master
    WHERE empcode = @empcode
  `;
  

  pool.request()
    .input('empcode', empcode)
    .query(fetchSql, (fetchErr, fetchResult) => {
      if (fetchErr) {
        console.error('Error fetching leave records: ', fetchErr);
        return res.status(500).json({ message: 'Error fetching leave records' });
      }
      const taskRecords = fetchResult.recordset.map(record => ({
        ID: record.ID,
        empcode: record.empcode,
        project: record.project,
        task_name: record.task_name,
        create_date: record.create_date,
        dept: record.dept,
        end_date: record.end_date,
        descr: record.descr,
        created_by: record.created_by,
        status: record.status,
      }));
      res.status(200).json({ taskRecords });
    });
    
};

exports.editTask = (req, res) => {
  const {
    ID,
    empcode,
    project,
    task_name,
    dept,
    descr,
    status,
    end_date
  } = req.body;
  const editSql = `
    UPDATE dbo.tbl_timesheet_task_master
    SET 
      project = @project,
      task_name = @task_name,
      dept = @dept,
      descr = @descr,
      status = @status,
      end_date = @end_date
    WHERE ID = @ID AND empcode = @empcode;
  `;
  pool.request()
    .input('ID', ID)
    .input('empcode', empcode)
    .input('project', project)
    .input('task_name', task_name)
    .input('dept', dept)
    .input('descr', descr)
    .input('status', status)
    .input('end_date', end_date)
    .query(editSql, (editErr, editResult) => {
      if (editErr) {
        console.error('Error updating task record:', editErr);
        return res.status(500).json({ message: 'Error editing Task record' });
      }
      res.status(200).json({ message: 'Task record edited successfully' });
    });
};

exports.createProject = async (req, res) => {
  let {
    team_lead_empcode,dept,companyid,createdby_empcode,status,date,
    project, deadline,description, member_empcodes} = req.body;

  // Trim whitespace from input fields
  team_lead_empcode = team_lead_empcode.trim();
  createdby_empcode = createdby_empcode.trim();
  project = project.trim();

  if (!team_lead_empcode || !createdby_empcode || !project || !companyid || isNaN(status)) {
    return res.status(400).send('Missing required fields');
  }

  let poolConnection;
  let teamLeadId;

  try {
    poolConnection = await pool.connect();

    // Start a transaction
    await poolConnection.request().query('BEGIN TRANSACTION');

    const teamLeadResult = await poolConnection.request()
      .input('team_lead_empcode', team_lead_empcode)
      .query('SELECT id FROM tbl_timesheet_employee WHERE team_lead = @team_lead_empcode');

    if (teamLeadResult.recordset.length === 0) {
      console.error('Team lead not found:', team_lead_empcode);
      const insertTeamLeadResult = await poolConnection.request()
        .input('team_lead_empcode', team_lead_empcode)
        .input('dept', dept || '')
        .input('companyid', companyid)
        .input('createdby', createdby_empcode)
        .input('date', date)
        .input('status', status)
        .input('project', project)
        .query(`
          INSERT INTO tbl_timesheet_employee (team_lead, dept, companyid, createdby, createddate,status, project)
          VALUES (@team_lead_empcode, @dept, @companyid, @createdby, @date,  @status, @project);
          SELECT SCOPE_IDENTITY() AS id;
        `);
      teamLeadId = insertTeamLeadResult.recordset[0].id;
    } else {
      teamLeadId = teamLeadResult.recordset[0].id;
    }

    for (const empcode of member_empcodes) {
      const trimmedEmpcode = empcode.trim();
      // Verify if member exists
      const memberCheckResult = await poolConnection.request()
        .input('empcode', trimmedEmpcode)
        .query('SELECT id FROM tbl_timesheet_insert_employee WHERE empcode = @empcode');

      if (memberCheckResult.recordset.length === 0) {
        await poolConnection.request()
          .input('e_id', teamLeadId)
          .input('empcode', trimmedEmpcode)
          .input('team_lead', team_lead_empcode)
          .input('deadline',deadline)
          .input('description',description)
          .input('project', project)
          .query(`
            INSERT INTO tbl_timesheet_insert_employee (e_id, empcode, team_lead, project,deadline,description)
            VALUES (@e_id, @empcode, @team_lead, @project,@deadline,@description);
          `);
      } else {
        console.error(`Member ${trimmedEmpcode} already exists in the project`);
      }
    }

    // Commit transaction
    await poolConnection.request().query('COMMIT TRANSACTION');

    res.status(201).send({ project });

  } catch (err) {
    console.error('Error creating project:', err);

    // Rollback transaction in case of error
    if (poolConnection) {
      await poolConnection.request().query('ROLLBACK TRANSACTION');
    }

    res.status(500).send('Error creating project');
  } finally {
    if (poolConnection) {
      poolConnection.release();
    }
  }
};

exports.fetchProjectAdmin = (req, res) => {
  const fetchSql = `
    SELECT p.e_id, p.empcode, p.team_lead, p.project, p.deadline, p.description,
           e.emp_fname AS team_member_name, l.emp_fname AS team_lead_name
    FROM tbl_timesheet_insert_employee p
    LEFT JOIN tbl_intranet_employee_jobDetails e ON p.empcode = e.empcode
    LEFT JOIN tbl_intranet_employee_jobDetails l ON p.team_lead = l.empcode
    ORDER BY p.e_id
  `;

  pool.request()
    .query(fetchSql, (fetchErr, fetchResult) => {
      if (fetchErr) {
        console.error('Error fetching project records: ', fetchErr);
        return res.status(500).json({ message: 'Error fetching project records' });
      }
      
      // Process the records to group team members by project
      const projectMap = new Map();
      
      fetchResult.recordset.forEach(record => {
        const { e_id, project, deadline, description, team_member_name, team_lead_name } = record;
        
        if (!projectMap.has(e_id)) {
          projectMap.set(e_id, {
            e_id, project, deadline, description,
            teamMembers: [],
            teamLead: team_lead_name
          });
        }
        
        if (team_member_name) {
          projectMap.get(e_id).teamMembers.push(team_member_name);
        }
      });
      
      const projectRecords = Array.from(projectMap.values());
      
      res.status(200).json({ projectRecords });
    });
}

exports.assignProjectTask = async (req, res) => {
  const { 
   project, task,status, description,assignee, deadline} = req.body;

  // Define SQL query with column names
  const insertSql = `
  INSERT INTO tbl_timesheet_task (
    project, task, status, description, assignee, deadline
  ) 
  VALUES (
    @project, @task, @status, @description, @assignee, CONVERT(date, @deadline, 23)
  )
`;

pool.request()
  .input('project',project)
  .input('task', task)
  .input('status', status)
  .input('description', description)
  .input('assignee', assignee || "") 
  .input('deadline', deadline)
  .query(insertSql)
  .then(result => {
    res.status(200).json({ message: 'Task record inserted successfully' });
  })
  .catch(err => {
    console.error('Error inserting task record: ', err);
    res.status(500).json({ message: 'Error inserting task record' });
  });
};

exports.fetchProjectTask = (req, res) => {
  const {project} = req.body;

  const fetchSql = `
    SELECT id, task, description, status, assignee, deadline
    FROM tbl_timesheet_task
    WHERE project = @project
  `;
  

  pool.request()
    .input('project', project)
    .query(fetchSql, (fetchErr, fetchResult) => {
      if (fetchErr) {
        console.error('Error fetching leave records: ', fetchErr);
        return res.status(500).json({ message: 'Error fetching leave records' });
      }
      const taskRecords = fetchResult.recordset.map(record => ({
        id: record.id,
        task: record.task,
        assignee:record.assignee,
        deadline: record.deadline,
        description: record.description,
        status: record.status ? 'Completed' : 'In Progress',
      }));
      res.status(200).json({ taskRecords });
    });
    
};

exports.editProjectTask = (req, res) => {
  const {id, project, task,description, status, deadline} = req.body;
  const editSql = `
    UPDATE tbl_timesheet_task
    SET 
      task = @task,
      description = @description,
      status = @status,
      deadline = @deadline
    WHERE id = @id AND project = @project;
  `;
  pool.request()
    .input('id', id)
    .input('project', project)
    .input('task', task)
    .input('description', description)
    .input('status', status)
    .input('deadline', deadline)
    .query(editSql, (editErr, editResult) => {
      if (editErr) {
        console.error('Error updating task record:', editErr);
        return res.status(500).json({ message: 'Error editing Task record' });
      }
      res.status(200).json({ message: 'Task record edited successfully' });
    });
};

exports.fetchProjectEmployee = (req, res) => {
  const { empcode } = req.body;
  const fetchSql = `
  SELECT 
    p.e_id, 
    p.project, 
    p.deadline, 
    p.description,
    e.emp_fname AS team_member_name, 
    l.emp_fname AS team_lead_name,
    STRING_AGG(te.emp_fname, ', ') AS all_team_member_names
FROM 
    tbl_timesheet_insert_employee p
    LEFT JOIN tbl_intranet_employee_jobDetails e ON p.empcode = e.empcode
    LEFT JOIN tbl_intranet_employee_jobDetails l ON p.team_lead = l.empcode
    LEFT JOIN tbl_timesheet_insert_employee pe ON p.e_id = pe.e_id
    LEFT JOIN tbl_intranet_employee_jobDetails te ON pe.empcode = te.empcode
WHERE 
    p.empcode = @empcode OR p.team_lead = @empcode 
GROUP BY 
    p.e_id, p.project, p.deadline, p.description, e.emp_fname, l.emp_fname
ORDER BY 
    p.e_id;
  `;

  pool.request()
  .input('empcode', empcode)
  .query(fetchSql, (fetchErr, fetchResult) => {
    if (fetchErr) {
      console.error('Error fetching project records: ', fetchErr);
      return res.status(500).json({ message: 'Error fetching project records' });
    }

    const projectMap = new Map();

    fetchResult.recordset.forEach(record => {
      const { e_id, project, deadline, description, team_member_name, team_lead_name, all_team_member_names } = record;

      if (!projectMap.has(e_id)) {
        projectMap.set(e_id, {
          e_id, project, deadline, description,
          teamMembers: all_team_member_names ? all_team_member_names.split(', ') : [],
          teamLead: team_lead_name
        });
      } else {
        const projectData = projectMap.get(e_id);
        if (all_team_member_names) {
          all_team_member_names.split(', ').forEach(name => {
            if (!projectData.teamMembers.includes(name)) {
              projectData.teamMembers.push(name);
            }
          });
        }
      }
    });

    const projectRecords = Array.from(projectMap.values());

    res.status(200).json({ projectRecords });
  });
};

