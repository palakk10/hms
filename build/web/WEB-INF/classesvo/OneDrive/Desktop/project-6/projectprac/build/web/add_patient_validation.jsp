<%@page import="java.sql.*" %>

<%
    String pid = request.getParameter("patientid");
    String pname = request.getParameter("patientname");
    String email = request.getParameter("email");
    String pwd = request.getParameter("pwd");
    String add = request.getParameter("add");
    String phone = request.getParameter("phone");
    String rov = request.getParameter("rov");
    String roomNo = request.getParameter("roomNo");
    String bedNo = request.getParameter("bed_no");
    String doctName = request.getParameter("doct"); // assuming this is doctor name
    String gender = request.getParameter("gender");
    String joindate = request.getParameter("joindate");
    String age = request.getParameter("age");
    String bgroup = request.getParameter("bgroup");

    Connection con = (Connection) application.getAttribute("connection");

    // Step 1: Get doctor ID by name
    int doctorId = -1;
    PreparedStatement ps = con.prepareStatement("SELECT ID FROM doctor_info WHERE NAME = ?");
    ps.setString(1, doctName);
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
        doctorId = rs.getInt("ID");
    } else {
        out.println("<h3 style='color:red;'>Doctor not found in the system. Please add the doctor first.</h3>");
        return;
    }
    rs.close();
    ps.close();

    // Step 2: Check if Room + Bed combination exists
    ps = con.prepareStatement("SELECT * FROM room_info WHERE ROOM_NO = ? AND BED_NO = ?");
    ps.setInt(1, Integer.parseInt(roomNo));
    ps.setInt(2, Integer.parseInt(bedNo));
    rs = ps.executeQuery();
    if (!rs.next()) {
        out.println("<h3 style='color:red;'>Invalid Room or Bed. Please add this Room/Bed first.</h3>");
        return;
    }
    rs.close();
    ps.close();

    // Step 3: Insert patient
    ps = con.prepareStatement(
        "INSERT INTO patient_info(pname, gender, age, bgroup, phone, rea_of_visit, room_no, bed_no, doctor_id, date_ad, email, password, address) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
    );

    ps.setString(1, pname);
    ps.setString(2, gender);
    ps.setInt(3, Integer.parseInt(age));
    ps.setString(4, bgroup);
    ps.setString(5, phone);
    ps.setString(6, rov);
    ps.setInt(7, Integer.parseInt(roomNo));
    ps.setInt(8, Integer.parseInt(bedNo));
    ps.setInt(9, doctorId);
    ps.setString(10, joindate);
    ps.setString(11, email);
    ps.setString(12, pwd);
    ps.setString(13, add);

    int i = ps.executeUpdate();

    if (i > 0) {
        ps = con.prepareStatement("UPDATE room_info SET status = ? WHERE room_no = ? AND bed_no = ?");
        ps.setString(1, "busy");
        ps.setInt(2, Integer.parseInt(roomNo));
        ps.setInt(3, Integer.parseInt(bedNo));
        ps.executeUpdate();
%>
        <div style="text-align:center;margin-top:25%">
        <font color="magenta">
        <script type="text/javascript">
            function Redirect() {
                window.location = "patients.jsp";
            }
            document.write("<h2>Patient Added Successfully</h2><br><br>");
            document.write("<h3>Redirecting you to home page....</h3>");
            setTimeout('Redirect()', 3000);
        </script>
        </font>
        </div>
<%
    }

    ps.close();
    con.commit();
%>
