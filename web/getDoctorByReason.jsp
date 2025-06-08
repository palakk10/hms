<%@ page import="java.sql.*" %>
<%
    String reason = request.getParameter("reason");
    Connection con = (Connection) application.getAttribute("connection");
    PreparedStatement deptStmt = null;
    PreparedStatement doctorStmt = null;
    ResultSet deptRs = null;
    ResultSet doctorRs = null;
    String jsonResponse = "{}";

    try {
        // Step 1: Get department ID from reason
        String getDeptIdQuery = "SELECT DEPT_ID FROM reason_department_mapping WHERE LOWER(REASON) = ?";
        deptStmt = con.prepareStatement(getDeptIdQuery);
        deptStmt.setString(1, reason.toLowerCase());
        deptRs = deptStmt.executeQuery();

        int deptId = -1;
        if (deptRs.next()) {
            deptId = deptRs.getInt("DEPT_ID");
        } else {
            // Fallback: General Physician (DEPT_ID = 1)
            deptId = 1;
        }

        // Step 2: Get a random doctor from that department
        String doctorQuery = "SELECT ID, NAME FROM doctor_info WHERE DEPT_ID = ? ORDER BY RAND() LIMIT 1";
        doctorStmt = con.prepareStatement(doctorQuery);
        doctorStmt.setInt(1, deptId);
        doctorRs = doctorStmt.executeQuery();

        if (doctorRs.next()) {
            int doctorId = doctorRs.getInt("ID");
            String doctorName = doctorRs.getString("NAME");
            jsonResponse = String.format("{\"doctorId\":%d,\"doctorName\":\"%s\"}", doctorId, doctorName.replace("\"", "\\\""));
        } else {
            // Fallback: Any doctor
            doctorStmt = con.prepareStatement("SELECT ID, NAME FROM doctor_info ORDER BY RAND() LIMIT 1");
            doctorRs = doctorStmt.executeQuery();
            if (doctorRs.next()) {
                int doctorId = doctorRs.getInt("ID");
                String doctorName = doctorRs.getString("NAME");
                jsonResponse = String.format("{\"doctorId\":%d,\"doctorName\":\"%s\"}", doctorId, doctorName.replace("\"", "\\\""));
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        if (doctorRs != null) try { doctorRs.close(); } catch (SQLException e) {}
        if (deptRs != null) try { deptRs.close(); } catch (SQLException e) {}
        if (doctorStmt != null) try { doctorStmt.close(); } catch (SQLException e) {}
        if (deptStmt != null) try { deptStmt.close(); } catch (SQLException e) {}
    }

    response.setContentType("application/json");
    out.print(jsonResponse);
%>