
<%@page import="java.sql.*, java.util.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add Patient Validation</title>
</head>
<body>
    <div style="text-align:center;margin-top:35%">
    <%
        // Retrieve form parameters
        String pid = request.getParameter("patientid");
        String pname = request.getParameter("patientname");
        String email = request.getParameter("email");
        String pwd = request.getParameter("pwd");
        String street = request.getParameter("street");
        String area = request.getParameter("area");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String pincode = request.getParameter("pincode");
        String country = request.getParameter("country");
        String phone = request.getParameter("phone");
        String rov = request.getParameter("rov");
        String probDesc = request.getParameter("prob_desc");
        String roomNo = request.getParameter("roomNo");
        String bedNo = request.getParameter("bed_no"); // Matches patients.jsp
        String doctId = request.getParameter("doct");
        String gender = request.getParameter("gender");
        String joindate = request.getParameter("joindate");
        String age = request.getParameter("age");
        String bgroup = request.getParameter("bgroup");

        Connection con = null;
        PreparedStatement ps = null;
        PreparedStatement statusCheckPs = null;
        PreparedStatement updateStatusPs = null;
        ResultSet rs = null;
        try {
            // Get database connection
            con = (Connection) application.getAttribute("connection");
            if (con == null) {
                Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "password");
            }

            // Basic validation
            if (pname == null || pname.trim().isEmpty()) {
                %>
                <font color="red">
                <script type="text/javascript">
                function Redirect() { window.location="patients.jsp"; }
                document.write("<h2>Error: Patient name is required.</h2><br><br>");
                document.write("<h3>Redirecting you to patient form...</h3>");
                setTimeout('Redirect()', 3000);
                </script>
                </font>
                <%
                return;
            }
            if (email == null || email.trim().isEmpty()) {
                %>
                <font color="red">
                <script type="text/javascript">
                function Redirect() { window.location="patients.jsp"; }
                document.write("<h2>Error: Email is required.</h2><br><br>");
                document.write("<h3>Redirecting you to patient form...</h3>");
                setTimeout('Redirect()', 3000);
                </script>
                </font>
                <%
                return;
            }
            if (pwd == null || pwd.trim().isEmpty() || pwd.length() < 8) {
                %>
                <font color="red">
                <script type="text/javascript">
                function Redirect() { window.location="patients.jsp"; }
                document.write("<h2>Error: Password must be at least 8 characters.</h2><br><br>");
                document.write("<h3>Redirecting you to patient form...</h3>");
                setTimeout('Redirect()', 3000);
                </script>
                </font>
                <%
                return;
            }
            if (phone == null || !phone.matches("\\d{10}")) {
                %>
                <font color="red">
                <script type="text/javascript">
                function Redirect() { window.location="patients.jsp"; }
                document.write("<h2>Error: Phone must be 10 digits.</h2><br><br>");
                document.write("<h3>Redirecting you to patient form...</h3>");
                setTimeout('Redirect()', 3000);
                </script>
                </font>
                <%
                return;
            }
            if (pincode == null || !pincode.matches("\\d{6}")) {
                %>
                <font color="red">
                <script type="text/javascript">
                function Redirect() { window.location="patients.jsp"; }
                document.write("<h2>Error: Pincode must be 6 digits.</h2><br><br>");
                document.write("<h3>Redirecting you to patient form...</h3>");
                setTimeout('Redirect()', 3000);
                </script>
                </font>
                <%
                return;
            }
            if (joindate == null || joindate.trim().isEmpty()) {
                %>
                <font color="red">
                <script type="text/javascript">
                function Redirect() { window.location="patients.jsp"; }
                document.write("<h2>Error: Admission date is required.</h2><br><br>");
                document.write("<h3>Redirecting you to patient form...</h3>");
                setTimeout('Redirect()', 3000);
                </script>
                </font>
                <%
                return;
            }
            if (roomNo == null || roomNo.trim().isEmpty()) {
                %>
                <font color="red">
                <script type="text/javascript">
                function Redirect() { window.location="patients.jsp"; }
                document.write("<h2>Error: Room number is required.</h2><br><br>");
                document.write("<h3>Redirecting you to patient form...</h3>");
                setTimeout('Redirect()', 3000);
                </script>
                </font>
                <%
                return;
            }
            if (bedNo == null || bedNo.trim().isEmpty()) {
                %>
                <font color="red">
                <script type="text/javascript">
                function Redirect() { window.location="patients.jsp"; }
                document.write("<h2>Error: Bed number is required.</h2><br><br>");
                document.write("<h3>Redirecting you to patient form...</h3>");
                setTimeout('Redirect()', 3000);
                </script>
                </font>
                <%
                return;
            }

            // Validate room and bed
            Integer roomNoInt = Integer.parseInt(roomNo);
            Integer bedNoInt = Integer.parseInt(bedNo);

            // Check if room and bed exist and are available
            statusCheckPs = con.prepareStatement("SELECT status FROM room_info WHERE room_no = ? AND bed_no = ?");
            statusCheckPs.setInt(1, roomNoInt);
            statusCheckPs.setInt(2, bedNoInt);
            rs = statusCheckPs.executeQuery();
            if (!rs.next()) {
                %>
                <font color="red">
                <script type="text/javascript">
                function Redirect() { window.location="patients.jsp"; }
                document.write("<h2>Error: Room <%=roomNo%> with Bed <%=bedNo%> does not exist.</h2><br><br>");
                document.write("<h3>Redirecting you to patient form...</h3>");
                setTimeout('Redirect()', 3000);
                </script>
                </font>
                <%
                return;
            }
            String currentStatus = rs.getString("status");
            if (!"Available".equalsIgnoreCase(currentStatus)) {
                %>
                <font color="red">
                <script type="text/javascript">
                function Redirect() { window.location="patients.jsp"; }
                document.write("<h2>Error: Room <%=roomNo%>, Bed <%=bedNo%> is already occupied.</h2><br><br>");
                document.write("<h3>Redirecting you to patient form...</h3>");
                setTimeout('Redirect()', 3000);
                </script>
                </font>
                <%
                return;
            }

            // Begin transaction
            con.setAutoCommit(false);

            // Insert patient
            ps = con.prepareStatement(
                "INSERT INTO patient_info (PNAME, GENDER, AGE, BGROUP, PHONE, STREET, AREA, CITY, STATE, PINCODE, COUNTRY, REA_OF_VISIT, PROBLEM_DESCRIPTION, ROOM_NO, BED_NO, DOCTOR_ID, DATE_AD, EMAIL, PASSWORD) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS
            );
            ps.setString(1, pname);
            ps.setString(2, gender != null ? gender : "");
            ps.setInt(3, age != null && !age.isEmpty() ? Integer.parseInt(age) : 0);
            ps.setString(4, bgroup != null ? bgroup : "");
            ps.setString(5, phone);
            ps.setString(6, street != null ? street : "");
            ps.setString(7, area != null ? area : "");
            ps.setString(8, city != null ? city : "");
            ps.setString(9, state != null ? state : "");
            ps.setString(10, pincode != null ? pincode : "");
            ps.setString(11, country != null ? country : "");
            ps.setString(12, rov != null ? rov : "");
            ps.setString(13, probDesc != null ? probDesc : "");
            ps.setInt(14, roomNoInt);
            ps.setInt(15, bedNoInt);
            ps.setObject(16, doctId != null && !doctId.isEmpty() ? Integer.parseInt(doctId) : null);
            ps.setString(17, joindate);
            ps.setString(18, email);
            ps.setString(19, pwd);

            int rowsAffected = ps.executeUpdate();
            int generatedId = 0;
            if (rowsAffected > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    generatedId = rs.getInt(1);
                }

                // Update room status to Occupied
                updateStatusPs = con.prepareStatement("UPDATE room_info SET status = 'Occupied' WHERE room_no = ? AND bed_no = ?");
                updateStatusPs.setInt(1, roomNoInt);
                updateStatusPs.setInt(2, bedNoInt);
                int statusUpdated = updateStatusPs.executeUpdate();
                if (statusUpdated == 0) {
                    throw new SQLException("Failed to update room status for Room " + roomNoInt + ", Bed " + bedNoInt);
                } else {
                    System.out.println("Updated status to Occupied for Room " + roomNoInt + ", Bed " + bedNoInt);
                }

                // Commit transaction
                con.commit();

                %>
                <font color="green">
                <script type="text/javascript">
                function Redirect() { window.location="patients.jsp"; }
                document.write("<h2>Patient Added Successfully! Patient ID: <%=generatedId%></h2><br><br>");
                document.write("<h3>Redirecting you to patient form...</h3>");
                setTimeout('Redirect()', 3000);
                </script>
                </font>
                <%
            } else {
                con.rollback();
                %>
                <font color="red">
                <script type="text/javascript">
                function Redirect() { window.location="patients.jsp"; }
                document.write("<h2>Error: Failed to add patient.</h2><br><br>");
                document.write("<h3>Redirecting you to patient form...</h3>");
                setTimeout('Redirect()', 3000);
                </script>
                </font>
                <%
            }
        } catch (SQLException e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            %>
            <font color="red">
            <script type="text/javascript">
            function Redirect() { window.location="patients.jsp"; }
            document.write("<h2>Database Error: <%=e.getMessage()%></h2><br><br>");
            document.write("<h3>Redirecting you to patient form...</h3>");
            setTimeout('Redirect()', 3000);
            </script>
            </font>
            <%
            e.printStackTrace();
        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            %>
            <font color="red">
            <script type="text/javascript">
            function Redirect() { window.location="patients.jsp"; }
            document.write("<h2>Unexpected Error: <%=e.getMessage()%></h2><br><br>");
            document.write("<h3>Redirecting you to patient form...</h3>");
            setTimeout('Redirect()', 3000);
            </script>
            </font>
            <%
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (statusCheckPs != null) try { statusCheckPs.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (updateStatusPs != null) try { updateStatusPs.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (con != null) try { con.setAutoCommit(true); } catch (SQLException e) { e.printStackTrace(); }
        }
    %>
    </div>
</body>
</html>
```