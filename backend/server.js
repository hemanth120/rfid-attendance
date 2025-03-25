
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const http = require('http');
const WebSocket = require('ws');
const mqtt = require('mqtt');
const mysql = require('mysql2/promise');
const multer = require('multer');
const xlsx = require('xlsx');

const app = express();
const port = 3001;

// Keep only the RFID topic
const rfidTopic = 'rfid/data';

app.use(cors());
app.use(bodyParser.json());


const server = http.createServer(app);
const wss = new WebSocket.Server({ server });
const upload = multer({ dest: 'uploads/' });

let rfidData = '';

// MySQL connection setup
const mysqlConfig = {
  host: 'localhost',
  user: 'root',
  password: 'Maybe@123',
  database: 'attendance_system'
};

// MQTT connection setup
const mqttClient = mqtt.connect('mqtt://34.131.24.103:1883');

mqttClient.on('connect', function () {
  console.log('Connected to broker');
  mqttClient.subscribe(rfidTopic);
});

// Add this to your existing server.js

app.post('/login', async (req, res) => {
  const { studentid, password } = req.body;

  try {
    const connection = await mysql.createConnection(mysqlConfig);

    const [rows] = await connection.execute(
      'SELECT studentid FROM user_credentials WHERE studentid = ? AND password = ?',
      [studentid, password]
    );

    await connection.end();

    if (rows.length > 0) {
      res.json({ studentid: rows[0].studentid });
    } else {
      res.status(401).json({ message: 'Invalid student ID or password' });
    }
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});
app.post('/admin/login', async (req, res) => {
  const { adminid, password } = req.body;

  try {
    const connection = await mysql.createConnection(mysqlConfig);

    const [rows] = await connection.execute(
      'SELECT adminid FROM admin_credentials WHERE adminid = ? AND password = ?',
      [adminid, password]
    );

    await connection.end();

    if (rows.length > 0) {
      res.json({ adminid: rows[0].adminid });
    } else {
      res.status(401).json({ message: 'Invalid admin ID or password' });
    }
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});


mqttClient.on('message', async function (topic, message) {
  if (topic === rfidTopic) {
    rfidData = message.toString();
    console.log(`Received RFID data: ${rfidData}`);

    // Get the current date and time
    const currentDate = new Date();
    const timestamp = currentDate.toISOString().slice(0, 19).replace('T', ' ');
    const currentDay = currentDate.toLocaleDateString('en-US', { weekday: 'long' });

    try {
      const connection = await mysql.createConnection(mysqlConfig);

      // Query to find matching studentid using rfidData
      const [studentRows] = await connection.execute(
        `SELECT studentid, name FROM studentinfo WHERE rfiddata = ?`,
        [rfidData]
      );

      if (studentRows.length > 0) {
        const studentid = studentRows[0].studentid;
        const studentName = studentRows[0].name;

        // Query to find matching timetable entry
        const [timetableRows] = await connection.execute(
          `SELECT subject, start_time FROM timetable WHERE day = ? AND start_time <= ? AND end_time >= ?`,
          [currentDay, currentDate.toTimeString().slice(0, 8), currentDate.toTimeString().slice(0, 8)]
        );

        if (timetableRows.length > 0) {
          const subject = timetableRows[0].subject;
          const startTime = timetableRows[0].start_time;

          // Calculate the time difference between current time and start time
          const startTimeDate = new Date(`${currentDate.toISOString().slice(0, 10)} ${startTime}`);
          const timeDifference = (currentDate - startTimeDate) / (1000 * 60); // Difference in minutes

          // Check if the student submitted within the first 20 minutes of the start time
          const isOnTime = timeDifference <= 20;

          // Record attendance with studentid and mark as 'Present' or 'Absent'
          await connection.execute(
            `INSERT INTO attendance (studentid, date, time, subject, status) VALUES (?, ?, ?, ?, ?)`,
            [studentid, currentDate.toISOString().slice(0, 10), currentDate.toTimeString().slice(0, 8), subject, isOnTime ? 'Present' : 'Absent']
          );

          console.log(`Attendance recorded for student ID ${studentid} (Student: ${studentName}) in subject ${subject} at ${currentDate.toTimeString().slice(0, 8)} on ${currentDay}. Status: ${isOnTime ? 'Present' : 'Absent'}`);

          // Send data to WebSocket clients
          wss.clients.forEach(client => {
            if (client.readyState === WebSocket.OPEN) {
              client.send(JSON.stringify({ studentid, studentName, subject, currentTime: currentDate.toTimeString().slice(0, 8), currentDay, status: isOnTime ? 'Present' : 'Absent' }));
            }
          });
        } else {
          console.log('No matching class found for the current time.');
        }
      } else {
        console.log(`RFID ${rfidData} does not match any student in the database.`);
      }

      await connection.end();
    } catch (error) {
      console.error('Database error:', error);
    }
  }
});

// Function to mark all students as "Absent" if no RFID data is received within 20 minutes of class start time
const markAbsentIfNoData = async () => {
  try {
    const currentDate = new Date();
    const currentDay = currentDate.toLocaleDateString('en-US', { weekday: 'long' });
    const currentTime = currentDate.toTimeString().slice(0, 8);

    const connection = await mysql.createConnection(mysqlConfig);

    // Query to find classes that started 20 minutes ago
    const [timetableRows] = await connection.execute(
      `SELECT subject, start_time FROM timetable WHERE day = ? AND start_time <= ? AND end_time >= ?`,
      [currentDay, currentTime, currentTime]
    );

    if (timetableRows.length > 0) {
      const subject = timetableRows[0].subject;
      const startTime = timetableRows[0].start_time;
      const startTimeDate = new Date(`${currentDate.toISOString().slice(0, 10)} ${startTime}`);

      // Calculate time difference to check if it's exactly 20 minutes after start time
      const timeDifference = (currentDate - startTimeDate) / (1000 * 60); // Difference in minutes

      if (timeDifference >= 20 && timeDifference <= 21) { // Slight buffer for timing issues
        // Mark all students as "Absent" for this subject and time if no record is found
        const [students] = await connection.execute(
          `SELECT studentid FROM studentinfo`
        );

        for (let student of students) {
          const studentid = student.studentid;

          // Check if the student is already marked "Present" for this subject and time
          const [attendanceRows] = await connection.execute(
            `SELECT * FROM attendance WHERE studentid = ? AND date = ? AND subject = ? AND time BETWEEN ? AND ?`,
            [studentid, currentDate.toISOString().slice(0, 10), subject, startTime, `${startTimeDate.getHours() + 1}:00:00`]
          );

          if (attendanceRows.length === 0) {
            // If no "Present" record found, mark as "Absent"
            await connection.execute(
              `INSERT INTO attendance (studentid, date, time, subject, status) VALUES (?, ?, ?, ?, 'Absent')`,
              [studentid, currentDate.toISOString().slice(0, 10), startTime, subject]
            );

            console.log(`Attendance recorded as "Absent" for student ID ${studentid} in subject ${subject}.`);
          }
        }
      }
    }

    await connection.end();
  } catch (error) {
    console.error('Database error:', error);
  }
};

// Run the check every minute to mark absences
setInterval(markAbsentIfNoData, 30000); // Every 60 seconds



wss.on('connection', (ws) => {
  console.log('WebSocket connection established');
  ws.send(JSON.stringify({ rfidData }));
  ws.on('message', (message) => {
    console.log(`Received message from client: ${message}`);
  });
});
// Add this route to the existing server.js file
// Add this route to the existing server.js file

app.get('/attendance', async (req, res) => {
  const { rfid_id } = req.query;

  try {
    const connection = await mysql.createConnection(mysqlConfig);

    const [rows] = await connection.execute(
      'SELECT studentid, subject, classes_conducted, classes_present, classes_absent, percentage FROM attendance_summary WHERE studentid = ?',
      [rfid_id]

    );

    await connection.end();

    if (rows.length > 0) {
      res.json(rows); // Send all matching rows
    } else {
      res.status(404).json({ message: 'No attendance records found for this RFID ID' });
    }
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});
app.post('/admin/add-student', async (req, res) => {
  const { rfiddata, studentid, name } = req.body;

  try {
    const connection = await mysql.createConnection(mysqlConfig);

    await connection.execute(
      'INSERT INTO studentinfo (rfiddata, studentid, name) VALUES (?, ?, ?)',
      [rfiddata, studentid, name]
    );

    await connection.end();

    res.status(200).json({ message: 'Student added successfully' });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

app.get('/attendance/subject/:subject', async (req, res) => {
  const { subject } = req.params;
  const { rfid_id } = req.query;

  try {
    const connection = await mysql.createConnection(mysqlConfig);

    const [rows] = await connection.execute(
      'SELECT date, time, status FROM attendance WHERE studentid = ? AND subject = ?',
      [rfid_id, subject]
    );

    await connection.end();

    if (rows.length > 0) {
      res.json(rows); // Send all matching rows
    } else {
      res.status(404).json({ message: 'No attendance records found for this subject and RFID ID' });
    }
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ message: 'Server error' });       
  }
});

app.get('/attendance/subjectwise', async (req, res) => {
  const { rfid_id } = req.query;

  try {
    const connection = await mysql.createConnection(mysqlConfig);

    const [rows] = await connection.execute(
      'SELECT subject, date, time, status FROM attendance WHERE studentid = ?',
      [rfid_id]
    );

    await connection.end();

    if (rows.length > 0) {
      // Group attendance records by subject
      const subjectWise = rows.reduce((acc, record) => {
        if (!acc[record.subject]) {
          acc[record.subject] = [];
        }
        acc[record.subject].push({
          date: record.date,
          time: record.time,
          status: record.status
        });
        return acc;
      }, {});

      res.json(subjectWise); // Send grouped records
    } else {
      res.status(404).json({ message: 'No attendance records found for this RFID ID' });
    }
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

app.get('/attendance/percentage', async (req, res) => {
  const { rfid_id } = req.query;

  try {
    const connection = await mysql.createConnection(mysqlConfig);

    // Query to get total classes and attended classes for each subject
    const [rows] = await connection.execute(
       `SELECT subject, COUNT(*) AS total_classes,
             SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) AS attended_classes
      FROM attendance
      WHERE studentid = ?
      GROUP BY subject
    `,
    
      [rfid_id]
    );

    await connection.end();

    if (rows.length > 0) {
      // Calculate percentage
      const percentages = rows.map(record => ({
        subject: record.subject,
        percentage: (record.attended_classes / record.total_classes * 100).toFixed(2)
      }));

      res.json(percentages);
    } else {
      res.status(404).json({ message: 'No attendance records found for this RFID ID' });
    }
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});
app.post('/admin/add-credentials', async (req, res) => {
  const { studentid, password } = req.body;

  try {
    const connection = await mysql.createConnection(mysqlConfig);

    // Query to check if the user already exists
    const [existingUser] = await connection.execute(
      'SELECT * FROM user_credentials WHERE studentid = ?',
      [studentid]
    );

    if (existingUser.length > 0) {
      // Update credentials if the user exists
      await connection.execute(
        'UPDATE user_credentials SET password = ? WHERE studentid = ?',
        [password, studentid]
      );
      res.json({ message: 'Credentials updated successfully' });
    } else {
      // Insert new user credentials if the user does not exist
      await connection.execute(
        'INSERT INTO user_credentials (studentid, password) VALUES (?, ?)',
        [studentid, password]
      );
      res.json({ message: 'Credentials added successfully' });
    }

    await connection.end();
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});
app.get('/admin/attendance-summary', async (req, res) => {
  try {
    const connection = await mysql.createConnection(mysqlConfig);

    // Query to get the attendance summary for all students
    const [rows] = await connection.execute(
      `SELECT studentid,
              subject,
              classes_conducted,
              classes_present,
              classes_absent,
              percentage
       FROM attendance_summary
      `
    );

    await connection.end();

    if (rows.length > 0) {
      res.json(rows);
    } else {
      res.status(404).json({ message: 'No attendance summaries found' });
    }
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

app.post('/upload-timetable', upload.single('file'), async (req, res) => {
  const file = req.file;
  if (!file) {
    return res.status(400).send('No file uploaded');
  }

  const connection = await mysql.createConnection(mysqlConfig);

  try {
    // Read the uploaded Excel file
    const workbook = xlsx.readFile(file.path);
    const sheetName = workbook.SheetNames[0];
    const sheetData = xlsx.utils.sheet_to_json(workbook.Sheets[sheetName]);

    // Log the sheetData to inspect the structure
    console.log(sheetData);

    // Function to convert decimal time to HH:MM:SS format
    function decimalToTime(decimal) {
      const hours = Math.floor(decimal * 24);
      const minutes = Math.floor((decimal * 24 - hours) * 60);
      const seconds = Math.round(((decimal * 24 - hours) * 60 - minutes) * 60);

      // Ensure hours, minutes, and seconds are in two-digit format
      return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
    }

    // Prepare data for insertion with validation for missing or invalid data
    const values = sheetData.map((row) => [
      row.day || 'Unknown', // Ensure day is valid
      decimalToTime(row.start_time), // Convert start_time to HH:MM:SS
      decimalToTime(row.end_time), // Convert end_time to HH:MM:SS
      row.subject || 'No Subject' // Default subject if missing
    ]);

    // Log the values array to ensure data is correct
    console.log(values);

    // Clear existing timetable in the database
    await connection.execute('DELETE FROM timetable');

    // Insert new timetable data
    const insertQuery = 'INSERT INTO timetable (day, start_time, end_time, subject) VALUES ?';
    await connection.query(insertQuery, [values]);

    res.send('Timetable updated successfully');
  } catch (err) {
    console.error('Error updating timetable:', err);
    res.status(500).send('Database error');
  } finally {
    await connection.end(); // Close the connection properly
  }
});


app.get('/rfidData', (req, res) => {
  res.json({ rfidData });
});

server.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
