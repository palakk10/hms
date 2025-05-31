<%@page import="java.sql.*"%>
<%
    Connection c = (Connection)application.getAttribute("connection");

    String patientName = request.getParameter("patientname");
    String email = request.getParameter("email");
    String address = request.getParameter("add");
    String phone = request.getParameter("phone");
    String reasonOfVisit = request.getParameter("rov");
    String probDesc = request.getParameter("prob_desc");
    String roomNoStr = request.getParameter("roomNo");
    String bedNoStr = request.getParameter("bed_no");
    String gender = request.getParameter("gender");
    String admitDate = request.getParameter("joindate");
    String ageStr = request.getParameter("age");
    String bgroup = request.getParameter("bgroup");

    int roomNo = 0, bedNo = 0, age = 0;

    try {
        roomNo = Integer.parseInt(roomNoStr);
    } catch(Exception e) { roomNo = 0; }
    try {
        bedNo = Integer.parseInt(bedNoStr);
    } catch(Exception e) { bedNo = 0; }
    try {
        age = Integer.parseInt(ageStr);
    } catch(Exception e) { age = 0; }

    String assignedDoctor = null;

    PreparedStatement psDoc = null;
    ResultSet rsDoc = null;

    if(reasonOfVisit != null && !reasonOfVisit.trim().isEmpty()) {
        String sql = "SELECT doctor_name FROM doctor_info WHERE specialization LIKE ? LIMIT 1";
        psDoc = c.prepareStatement(sql);

        String lowerRov = reasonOfVisit.toLowerCase();

        if(lowerRov.contains("cardio")) {
            psDoc.setString(1, "%cardio%");
        } else if(lowerRov.contains("ortho")) {
            psDoc.setString(1, "%ortho%");
        } else if(lowerRov.contains("neuro")) {
            psDoc.setString(1, "%neuro%");
        } else if(lowerRov.contains("general")) {
            psDoc.setString(1, "%general%");
        } else {
            psDoc.setString(1, "%general%");
        }

        rsDoc = psDoc.executeQuery();
        if(rsDoc.next()) {
            assignedDoctor = rsDoc.getString(1);
        }
    }

    if(assignedDoctor == null) {
        // fallback: pick any doctor
        psDoc = c.prepareStatement("SELECT doctor_name FROM doctor_info LIMIT 1");
        rsDoc = psDoc.executeQuery();
        if(rsDoc.next()) {
            assignedDoctor = rsDoc.getString(1);
        }
    }

    PreparedStatement psInsert = c.prepareStatement("INSERT INTO patient_info(patient_name, gender, age, blood_group, phone, reason_of_visit, problem_description, room_no, bed_no, referred_to, admission_date, email, address) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)");
    psInsert.setString(1, patientName);
    psInsert.setString(2, gender);
    psInsert.setInt(3, age);
    psInsert.setString(4, bgroup);
    psInsert.setString(5, phone);
    psInsert.setString(6, reasonOfVisit);
    psInsert.setString(7, probDesc);
    psInsert.setInt(8, roomNo);
    psInsert.setInt(9, bedNo);
    psInsert.setString(10, assignedDoctor);
    psInsert.setString(11, admitDate);
    psInsert.setString(12, email);
    psInsert.setString(13, address);

    int res = psInsert.executeUpdate();

    if(res > 0) {
        response.sendRedirect("patient.jsp?msg=Patient added successfully");
    } else {
        response.sendRedirect("patient.jsp?msg=Failed to add patient");
    }
%>
